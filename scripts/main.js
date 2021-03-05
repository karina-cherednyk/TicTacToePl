let tips = false;
let tipElems = Array.from(document.getElementsByClassName('tooltiptext'))

const toggleTips = (e) => {
    let b = e.target;
    tips = !tips  
    b.innerText = b.innerText == tips ? 'Hide tips' : 'Show tips'  
    tipElems.forEach(x => x.style.display = tips ? 'block' : 'none')
}

const computeScoreIndex = (row, col, tooltip) => {
    const computeScore = async () => {
        if(tips)
            score(row,col, tooltip)
    }   
    return computeScore;
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
            tt.style.display = 'none'
            if(r == 0) tt.classList.add('top-tooltip')
            cell.appendChild(tt)
            cell.onmouseover = computeScoreIndex(r,c, tt)
            cell.onclick = (e) => setHuMove(e.target, r,c)
            row.appendChild(cell)
        }
    }
}

