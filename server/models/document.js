//document
// -user id
// created at
// title
// contents

const mongoose = require('mongoose');
const documentSchema = new mongoose.Schema({
    uid: {
        required: true,
        type: String
    },
    createdAt: {
        required: true,
        type: Number
    },
    title: {
        required: true,
        type: String,
        trim:true
    },
    contents: {
        type: Array,
        default: [],
    }
});

const Document=mongoose.model('Document',documentSchema);
module.exports = Document;