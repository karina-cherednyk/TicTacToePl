const toggleTips = (e) => {
    let b = e.target;
    b.innerText = b.innerText == 'Show tips' ? 'Hide tips' : 'Show tips'    
}

const computeScoreIndex = (row, col, tooltip) => {
    const computeScore = async () => {
        score(row,col, tooltip)
    }   
    return computeScore;
} 
const setMove = (cell, r, c) => {
    console.log(r+','+c)
    if(!cell.classList.contains('cross')){
        cell.classList.add('cross')
        b.board[r * b.c + c] = 'x'
    }
}

window.onload = () => {
    document.getElementById('toggleTips').onclick = toggleTips;
    const board = document.getElementById('board')

    for(let r =0; r < b.r; ++r){
        let row = document.createElement('row')
        board.appendChild(row)
        for(let c = 0; c < b.c; ++c){
            let cell = document.createElement('cell')
            let tt   = document.createElement('span')
            cell.classList.add('tooltip')
            tt.classList.add('tooltiptext')
            if(r == 0) tt.classList.add('top-tooltip')
            cell.appendChild(tt)
            cell.onmouseover = computeScoreIndex(r,c, tt)
            cell.onclick = (e) => setMove(e.target, r,c)
            row.appendChild(cell)
        }
    }
}

