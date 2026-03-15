document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault(); // Impede a página de recarregar

    const matricula = document.getElementById('matricula').value;
    const password = document.getElementById('password').value;
    const btnLogin = document.getElementById('btnLogin');

    // Feedback visual de "Loading"
    btnLogin.innerText = "VERIFICANDO...";
    btnLogin.disabled = true;

    try {
        // Aqui é onde você vai conectar com a API do Rafael
        const response = await fetch('http://localhost:3000/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ matricula, password })
        });

        const data = await response.json();

        if (response.ok) {
            alert("Acesso autorizado!");
            localStorage.setItem('token', data.token); // Salva o JWT
            window.location.href = 'dashboard.html';
        } else {
            alert(data.message || "Erro ao logar");
        }
    } catch (error) {
        console.error("Erro na conexão:", error);
        alert("Servidor offline. Verifique sua conexão.");
    } finally {
        btnLogin.innerText = "ENTRAR";
        btnLogin.disabled = false;
    }
});