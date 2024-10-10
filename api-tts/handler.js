require("dotenv").config();
const AWS = require("aws-sdk");
const BUCKET_NAME = process.env.S3_BUCKET;
const s3 = new AWS.S3();
const polly = new AWS.Polly();
const translate = new AWS.Translate();
const transcribeService = new AWS.TranscribeService();
exports.convertPolly = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const phrase2 = body.phrase;

    if (!phrase2) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Erro ao informar o texto" }),
      };
    }

    const audioName = `audio-${phrase2.split(" ")[0]}.mp3`;

    const pollyParams = {
      Text: phrase2,
      VoiceId: "Vitoria",
      OutputFormat: "mp3",
    };

    // Gera o áudio com Polly
    const pollyResult = await polly.synthesizeSpeech(pollyParams).promise();

    if (!pollyResult.AudioStream) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Erro ao processar audio" }),
      };
    }

    // Carrega o áudio no S3
    const s3Params = {
      Bucket: BUCKET_NAME,
      Key: audioName,
      Body: pollyResult.AudioStream,
      ContentType: "audio/mpeg",
    };

    await s3.putObject(s3Params).promise();

    const audioUrl = `https://${BUCKET_NAME}.s3.amazonaws.com/${audioName}`;

    return {
      statusCode: 200,
      body: JSON.stringify({
        received_phrase: phrase2,
        url_to_audio: audioUrl,
        created_audio: new Date().toLocaleString("pt-BR", {
          timeZone: "America/Sao_Paulo",
        }),
      }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};

exports.translate = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const text = body.text;
    const to = body.to;
    const from = body.from;

    if (!text) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Erro ao informar o texto" }),
      };
    }

    const translateParams = {
      SourceLanguageCode: from,
      TargetLanguageCode: to,
      Text: text,
    };

    const translateResult = await translate
      .translateText(translateParams)
      .promise();

    return {
      statusCode: 200,
      body: JSON.stringify({
        translated_text: translateResult.TranslatedText,
        from: translateResult.SourceLanguageCode,
        to: translateResult.TargetLanguageCode,
      }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};

exports.upload = async (event) => {
  try {
    const fileContent = Buffer.from(event.body, "base64");
    const fileName = event.headers["file-name"];
    console.log(fileName);
    // Carregar o áudio no S3
    const s3Params = {
      Bucket: BUCKET_NAME,
      Key: fileName,
      Body: fileContent,
      ContentType: "audio/aac",
    };

    // Upload do áudio para o S3
    await s3.putObject(s3Params).promise();
    console.log("Arquivo enviado para o S3 com sucesso!");
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "uploaded!",
      }),
    };
  } catch (e) {
    console.error("Erro:", e);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Erro ao fazer upload." }),
    };
  }
};

exports.transcribe = async (event) => {
  try {
    // Iniciar transcrição
    const transcribeResult = await transcribeAudio(event);
    const jobName = transcribeResult.TranscriptionJob.TranscriptionJobName;
    console.log("Transcrição iniciada:", jobName);

    // Verificar o status da transcrição em loop
    let transcriptionJob;
    let attempts = 0;
    const maxAttempts = 20; // Número máximo de tentativas
    const waitTime = 5000; // Tempo de espera em milissegundos

    while (attempts < maxAttempts) {
      transcriptionJob = await checkTranscriptionJob(jobName);

      if (transcriptionJob.TranscriptionJobStatus === "COMPLETED") {
        const transcriptionText = await getTranscriptionResult(
          transcriptionJob.Transcript.TranscriptFileUri
        );
        return {
          statusCode: 200,
          body: JSON.stringify({
            message: "Transcrição concluída!",
            text: transcriptionText,
          }),
        };
      } else if (transcriptionJob.TranscriptionJobStatus === "FAILED") {
        console.error("Transcrição falhou:", transcriptionJob);
        return {
          statusCode: 500,
          body: JSON.stringify({ message: "Transcrição falhou." }),
        };
      }

      // Log do status atual
      console.log("Transcrição em andamento. Tentativa:", attempts + 1);

      // Aguardar antes da próxima verificação
      attempts++;
      await new Promise((resolve) => setTimeout(resolve, waitTime));
    }

    console.log("Não terminou ainda");
    // Se atingiu o número máximo de tentativas
    return {
      statusCode: 202, // Transcrição ainda em andamento
      body: JSON.stringify({
        message: "Transcrição ainda em andamento.",
        jobName: jobName,
      }),
    };
  } catch (err) {
    console.error("Erro:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Erro ao fazer upload." }),
    };
  }
};

const transcribeAudio = async (event) => {
  const fileName = event.headers["file-name"];

  const params = {
    TranscriptionJobName: `TranscriptionJob-${Date.now()}`,
    LanguageCode: "pt-BR",
    MediaFormat: "mp4",
    Media: {
      MediaFileUri: `https://s3.us-east1-amazonaws.com/${BUCKET_NAME}/${fileName}`,
    },
    OutputBucketName: BUCKET_NAME,
  };

  try {
    const data = await transcribeService
      .startTranscriptionJob(params)
      .promise();
    return data;
  } catch (err) {
    console.error("Erro ao iniciar a transcrição:", err);
    throw new Error("Erro ao iniciar a transcrição.");
  }
};

const checkTranscriptionJob = async (jobName) => {
  const params = {
    TranscriptionJobName: jobName,
  };

  try {
    const data = await transcribeService.getTranscriptionJob(params).promise();
    return data.TranscriptionJob;
  } catch (err) {
    console.error("Erro ao obter o status do trabalho de transcrição:", err);
    throw new Error("Erro ao verificar o status da transcrição.");
  }
};

const getTranscriptionResult = async (transcriptUri) => {
  const response = await fetch(transcriptUri);
  const transcriptData = await response.json();
  return transcriptData.results.transcripts[0].transcript;
};

exports.hello = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Go Serverless v4! Your function executed successfully!",
    }),
  };
};
