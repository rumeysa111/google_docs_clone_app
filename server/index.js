const express = require('express');
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');
const Document = require('./models/document');
const app = express();
const jwt=require('jsonwebtoken');
const cors = require('cors');
const http = require('http');
const documentRouter = require('./routes/document');
var server=http.createServer(app);
const DB = "mongodb+srv://rumeysasmz:2003Rumeysa@cluster0.r1xyj.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
var io = require('socket.io')(server);
// express.json() middleware'ini kullanarak gelen isteklerin gövdesini JSON formatında ayrıştır

app.use(express.json());

app.use(authRouter);
app.use(documentRouter);

app.use(cors());

mongoose.connect(DB).then(() => {
    console.log("Connected to MongoDB");
}).catch((err) => console.log(err));

io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);  // Socket ID ile bağlantıyı kontrol edin.

    // Diğer olaylar
    socket.on('join', (documentId) => {
        socket.join(documentId);
        console.log('User joined document:', documentId);
    });

    socket.on('disconnect', () => {
        console.log('A user disconnected:', socket.id);
    });

    socket.on('typing', (data) => {
        socket.broadcast.to(data.room).emit('changes', data);
    });

    socket.on('save', (data) => {
        saveData(data);
    });
});

const saveData = async (data) => {
    let document = await Document.findById(data.room);
    if (!document) {
        console.log("Document not found");
        return;
    }
    document.data = data.delta;
    document = await document.save();
}

//async _> await
// .then(data) =>printdata
const PORT = process.env.PORT || 3001;
server.listen(PORT, "0.0.0.0", () => {
    console.log(`Server is running on port ${PORT}`);
 

}
);