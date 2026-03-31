document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault(); // Impede a página de recarregar

    const matricula = document.getElementById('matricula').value;
    const password = document.getElementById('password').value;
    const btnLogin = document.getElementById('btnLogin');

    // Feedback visual de "Loading"
    btnLogin.innerText = "VERIFICANDO...";
    btnLogin.disabled = true;

    try {
        const response = await fetch('http://localhost:3001/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ matricula, password })
        });

        const data = await response.json();

        console.log('Response:', response.status, data);
        
        if (response.ok) {
            localStorage.setItem('token', data.token);
            localStorage.setItem('usuario', JSON.stringify(data.usuario));
            alert("Login OK! Redirecionando...");
            window.location.href = 'dashboard.html';
        } else {
            alert(data.erro || "Erro ao logar: " + JSON.stringify(data));
        }
    } catch (error) {
        console.error("Erro na conexão:", error);
        alert("Servidor offline. Verifique sua conexão.");
    } finally {
        btnLogin.innerText = "ENTRAR";
        btnLogin.disabled = false;
    }
});