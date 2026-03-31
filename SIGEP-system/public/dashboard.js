function atualizarDataHora() {
    const agora = new Date();
    
    const dia = String(agora.getDate()).padStart(2, '0');
    const mes = String(agora.getMonth() + 1).padStart(2, '0');
    const ano = String(agora.getFullYear()).slice(-2);
    
    const hora = String(agora.getHours()).padStart(2, '0');
    const minuto = String(agora.getMinutes()).padStart(2, '0');
    
    document.getElementById('dataAtual').textContent = `${dia}/${mes}/${ano}`;
    document.getElementById('horaAtual').textContent = `${hora}:${minuto}`;
}

atualizarDataHora();
setInterval(atualizarDataHora, 1000);

const token = localStorage.getItem('token');
if (!token) {
    window.location.href = 'index.html';
}
