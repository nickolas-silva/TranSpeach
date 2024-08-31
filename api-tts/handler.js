const AWS = require('aws-sdk');
const BUCKET_NAME = "ttsbucket111";
const s3 = new AWS.S3();
const polly = new AWS.Polly();

exports.convertPolly = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const phrase2 = body.phrase;

    if (!phrase2) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Erro ao informar o texto' }),
      };
    }

    const audioName = `audio-${phrase2.split(' ')[0]}.mp3`;

    const pollyParams = {
      Text: phrase2,
      VoiceId: 'Vitoria',
      OutputFormat: 'mp3',
    };

    // Gera o áudio com Polly
    const pollyResult = await polly.synthesizeSpeech(pollyParams).promise();

    if (!pollyResult.AudioStream) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Erro ao processar audio' }),
      };
    }

    // Carrega o áudio no S3
    const s3Params = {
      Bucket: BUCKET_NAME,
      Key: audioName,
      Body: pollyResult.AudioStream,
      ContentType: 'audio/mpeg',
    };

    await s3.putObject(s3Params).promise();

    const audioUrl = `https://${BUCKET_NAME}.s3.amazonaws.com/${audioName}`;

    return {
      statusCode: 200,
      body: JSON.stringify({
        received_phrase: phrase2,
        url_to_audio: audioUrl,
        created_audio: new Date().toLocaleString('pt-BR', { timeZone: 'America/Sao_Paulo' }),
      }),
    };

  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
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