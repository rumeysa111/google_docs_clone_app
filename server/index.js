const express = require('express');
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');
const app = express();
const jwt=require('jsonwebtoken');
const cors = require('cors');
const documentRouter = require('./routes/document');

const DB = "mongodb+srv://rumeysasmz:2003Rumeysa@cluster0.r1xyj.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

// express.json() middleware'ini kullanarak gelen isteklerin gövdesini JSON formatında ayrıştır

app.use(express.json());

app.use(authRouter);
app.use(documentRouter);

app.use(cors());

mongoose.connect(DB).then(() => {
    console.log("Connected to MongoDB");
}).catch((err) => console.log(err));

//async _> await
// .then(data) =>printdata
const PORT = process.env.PORT || 3001;
app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server is running on port ${PORT}`);
 

}
);