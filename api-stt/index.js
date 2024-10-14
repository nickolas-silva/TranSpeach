require("dotenv").config();
const express = require("express");
const path = require("path");
const multer = require("multer");
const app = express();
const fs = require("fs");

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const { createClient } = require("@deepgram/sdk");

const deepgram = createClient(process.env.secretKey);

app.post("/speech-to-text", upload.single("audio"), async (req, res) => {
  if (!req.file) {
    return res.status(400).send("Nenhum arquivo foi enviado.");
  }
  const audioBuffer = req.file.buffer;

  const { result, error } = await deepgram.listen.prerecorded.transcribeFile(
    audioBuffer,
    {
      model: "nova-2",
      smart_format: true,
      language: "pt-BR",
    }
  );
  if (error) {
    return {
      statusCode: 500,
      err: error.message,
    };
  } else {
    const transcriptionText =
      result.results.channels[0].alternatives[0].transcript;
    console.log(transcriptionText);
    console.log(result);
    return res.json(transcriptionText);
  }
});

app.listen(3001);
