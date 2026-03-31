document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const matricula = document.getElementById('matricula').value;
    const password = document.getElementById('password').value;
    const btnLogin = document.getElementById('btnLogin');

    btnLogin.innerText = "VERIFICANDO...";
    btnLogin.disabled = true;

    console.log('Enviando login:', matricula);

    try {
        const response = await fetch('http://localhost:3001/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ matricula, senha: password })
        });

        const data = await response.json();
        console.log('Resposta do servidor:', response.status, data);
        
        if (response.ok) {
            console.log('Salvando token...');
            localStorage.setItem('token', data.token);
            localStorage.setItem('usuario', JSON.stringify(data.usuario));
            console.log('Token salvo:', localStorage.getItem('token'));
            console.log('Redirecionando para dashboard...');
            window.location.href = 'dashboard.html';
        } else {
            alert("Erro: " + (data.erro || "Credenciais inválidas"));
        }
    } catch (error) {
        console.error("Erro:", error);
        alert("Erro de conexão: " + error.message);
    } finally {
        btnLogin.innerText = "ENTRAR";
        btnLogin.disabled = false;
    }
});
