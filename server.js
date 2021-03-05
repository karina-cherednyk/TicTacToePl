const express = require('express')
const path = require('path')
const app = express()


var exec = require('child_process').exec;

app.use(express.json());
app.use(express.static('.'))

app.get('/', (_, res) => {
    res.sendFile(path.join(__dirname, './index.html'))
})

app.post('/pl', (req, res) => {
    const cmnd = `swipl -f ./TicTacToeScore.pl -g "${req.body.query},${req.body.goals},halt"`
    exec(cmnd, function (_, stdOut, _) {
       res.send(stdOut)
    });
})

app.listen(8066, ()=> {
    console.log('Server running on port 8066')
})

