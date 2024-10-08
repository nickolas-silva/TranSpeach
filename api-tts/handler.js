require("dotenv").config();
const AWS = require("aws-sdk");
const BUCKET_NAME = process.env.S3_BUCKET;
const s3 = new AWS.S3();
const polly = new AWS.Polly();
const translate = new AWS.Translate();
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

exports.transcribe = async (event) => {
  try {
    const transcribe = new AWS.TranscribeService();

    const { language, url_to_audio, outputBucketName } = event.body;

    const params = {
      TranscriptionJobName: "transcribe", // Nome do trabalho de transcrição
      LanguageCode: "pt-BR", // Idioma do áudio
      Media: {
        MediaFileUri: "s3://your-bucket/your-audio-file.mp3", // Caminho para o arquivo no S3
      },
      OutputBucketName: "your-output-bucket", // Bucket S3 para o arquivo de saída
      MediaFormat: "mp4", // Formato do arquivo de áudio (pode ser 'mp3', 'mp4', 'wav', 'flac')
    };

    transcribe.startTranscriptionJob(params, (err, data) => {
      if (err) {
        console.error("Erro ao iniciar a transcrição:", err);
      } else {
        console.log("Transcrição iniciada com sucesso:", data);
      }
    });
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};

exports.uploadToBucket = async (event) => {
  const fileContent = Buffer.from(event.body, "base64"); // O arquivo deve ser enviado como base64
  const fileName = event.headers["file-name"]; // O nome do arquivo deve ser passado no cabeçalho

  // Carrega o áudio no S3
  const s3Params = {
    Bucket: BUCKET_NAME,
    Key: fileName,
    Body: fileContent,
    ContentType: "audio/mpeg",
  };

  try {
    const data = await s3.putObject(s3Params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Upload bem-sucedido!",
        fileUrl: data.Location,
      }),
    };
  } catch (err) {
    console.log(err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Erro ao fazer upload." }),
    };
  }
};

exports.hello = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Go Serverless v4! Your function executed successfully!",
    }),
  };
};
