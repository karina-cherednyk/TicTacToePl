let b = {
    board: [],
    r: 10,
    c: 10
}
const cells = document.getElementsByTagName('cell')
function initBoard(){
    for(let i=0; i<b.r*b.c; ++i)
        b.board.push(0)
}
initBoard()
const boardPl = () =>  `b([${b.board.join(',')}], ${b.r}, ${b.c})`

const makeMove = (r, c, pl,res) => `makeEvalMove(${boardPl()},m(${r+1},${c+1}),${pl},${res})`
const makeTotalMove = (r, c, pl,res) => `moveTotalScore(${boardPl()},m(${r+1},${c+1}),${pl},${res})`


function getColor(score){
    const mainColor = [255, 235, 205]
    let coeff = 0
    let maxCoeff = 6
    for(let i=maxCoeff; i>1; --i){
        if(Math.pow(10,i) < score){
            coeff = i - 2
            break
        }
    }
    return  score==0 ? `rgb(${mainColor.join()})` : `rgb(${mainColor.map(c => c*(1- coeff/maxCoeff) ).join()})`
}

function changeRowColor(r, cols){
    for(let c=0; c<b.c; ++c){
        let color = getColor(cols[c])
        cells[r*b.c + c].style.backgroundColor = color
    }
}


function changeColors(){
    if(!tips) return

    for(let r=0; r<b.r; ++r){
        let row = Array.from(Array(b.c).keys())
        let query = `{
            "query": "${row.map(c => makeTotalMove(r,c,'x','Score'+r+c)).join()}",
            "goals": "${row.map(c => 'writeln(Score'+r+c+')').join()}"
            }`
        let xhttp = new XMLHttpRequest()
        xhttp.open("POST", "/pl", true)
        xhttp.setRequestHeader("Content-Type", "application/json");
        xhttp.send(query)
        xhttp.onreadystatechange = function() {
            if (this.readyState == 4 && this.status == 200) {
                let arr = this.responseText.split('\n')
                changeRowColor(r, arr)
            }
        };
    }
    
}
function request(query, callback) {
    let xhttp = new XMLHttpRequest()
    xhttp.open("POST", "/pl", true)
    xhttp.setRequestHeader("Content-Type", "application/json");
    xhttp.send(query)
    xhttp.onreadystatechange = function() {
        if(this.readyState == 4 && this.status == 200){
            callback(this.responseText)
        }
           
    }
        
        
       
}

function score(r, c, elem){
    // evalMove(B, Mv, Pl, Score) 
    let query = `{
        "query": "${makeMove(r,c,'x','ScorePlayer')}, ${makeMove(r,c,'x','ScoreAI')}",
        "goals": "writeln(ScorePlayer), writeln(ScoreAI)"
        }`
    const callback = (responseText) => {
            let arr = responseText.split('\n')
            elem.innerText = `User score:${arr[0]}\nAI score:${arr[1]}`
    };
    request(query, callback)
   
}
const setAiMove = () => {
    let query = `{
        "query": "aiMove(${boardPl()}, MoveAi, _), MoveAi=m(R,C), moveTotalScore(${boardPl()}, MoveAi, o, ScoreAi)",
        "goals": "writeln(R), writeln(C), write(ScoreAi)"
        }`
    const callback = (responseText) => {
            let arr = responseText.split('\n').map(x => parseInt(x))
            let [r,c,score] = arr
            let i = (r-1) * b.c + (c-1) 
            cells[i].classList.add('null')
            b.board[i] = 'o'
            if(score >= Math.pow(10,10))
                wins('AI')
            changeColors()
        }
    request(query, callback)
}
const setHuMove = (cell, r, c) => {
    if(!cell.classList.contains('cross')){
        // moveTotalScore(B,Mv,Pl,Score)
        let query = `{
            "query": "moveTotalScore(${boardPl()}, m(${r+1},${c+1}), x, ScorePl)",
            "goals": "writeln(ScorePl)"
            }`
        const callback = (responseText) => {
                let score = responseText
                cell.classList.add('cross')
                b.board[r * b.c + c] = 'x'
                if(score >= Math.pow(10,10))
                    wins('Player')
                else 
                    setAiMove()
                changeColors()
            }
        request(query, callback)
    }
}

const wins = (who) => {
    alert('Wins '+who)
    b.board = []
    Array.from(cells).forEach( c => c.classList.remove('null', 'cross') )
    initBoard()
} 
