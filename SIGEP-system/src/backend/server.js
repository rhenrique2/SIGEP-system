const express = require('express');
const cors = require('cors');
const pool = require('./db');
const security = require('./security');
const auth = require('./auth');

const app = express();
const path = require('path');

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../../public')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../../public/index.html'));
});

app.post('/usuarios', auth, async (req, res) => {
    const { 
        matricula, 
        senha, 
        nome_completo, 
        cpf, 
        data_nascimento, 
        estado_civil, 
        email_funcional, 
        cargo, 
        role 
    } = req.body;

    try {
        // CRITÉRIO 1: Validação de duplicados (Evita erro 500 desnecessário)
        const buscaDuplicado = await pool.query(
            'SELECT id FROM public.usuarios WHERE cpf = $1 OR email_funcional = $2',
            [cpf, email_funcional]
        );

        if (buscaDuplicado.rows.length > 0) {
            return res.status(400).json({ erro: "CPF ou E-mail já cadastrados no sistema." });
        }

        // CRITÉRIO 2: Implementação de Hash (Você já tem, mantivemos aqui)
        const senhaHash = await security.gerarHash(senha);

        const result = await pool.query(
            `INSERT INTO public.usuarios 
            (matricula, senha, nome_completo, cpf, data_nascimento, estado_civil, email_funcional, cargo, role) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id, nome_completo`,
            [
                matricula, 
                senhaHash, 
                nome_completo, 
                cpf, 
                data_nascimento || null, 
                estado_civil || 'NÃO INFORMADO', 
                email_funcional || null, 
                cargo || 'INSPETOR', 
                role || 'USER'
            ]
        );

        res.status(201).json({ 
            mensagem: "Funcionário registrado com sucesso!", 
            id: result.rows[0].id,
            nome: result.rows[0].nome_completo 
        });
    } catch (err) {
        console.error("[ERRO BANCO]:", err.message);
        res.status(500).json({ erro: "Falha ao registrar funcionário: " + err.message });
    }
});

// ROTA DE AUTENTICAÇÃO (LOGIN)
const jwt = require('jsonwebtoken');

app.post('/login', async (req, res) => {
    const { matricula, senha } = req.body;

    console.log('Login recebido:', matricula);

    try {
        console.log('Tentativa de login - matricula:', matricula, 'senha:', senha);
        
        const usuarioQuery = await pool.query(
            'SELECT * FROM public.usuarios WHERE matricula = $1',
            [matricula]
        );

        console.log('Usuario encontrado:', usuarioQuery.rows.length);

        if (usuarioQuery.rows.length === 0) {
            return res.status(401).json({ erro: "Credenciais inválidas." });
        }

        const usuario = usuarioQuery.rows[0];
        console.log('Senha do banco:', usuario.senha);
        const senhaValida = await security.compararSenha(senha, usuario.senha);

        if (!senhaValida) {
            return res.status(401).json({ erro: "Credenciais inválidas." });
        }

        // 2. GERANDO O TOKEN (O Crachá do SIGEP)
        const token = jwt.sign(
            { 
                id: usuario.id, 
                role: usuario.role,
                nome: usuario.nome_completo 
            }, 
            process.env.JWT_SECRET, // Usa a chave que você salvou no .env
            { expiresIn: '8h' }    // O token expira em 8 horas por segurança
        );

        // 3. RETORNANDO O TOKEN PARA O FRONT-END
        res.json({
            mensagem: "Login autorizado com sucesso!",
            token: token, // Envia o código criptografado
            usuario: {
                nome: usuario.nome_completo,
                role: usuario.role,
                cargo: usuario.cargo
            }
        });

    } catch (err) {
        console.error("[ERRO LOGIN]:", err);
        res.status(500).json({ erro: "Erro interno no servidor SIGEP: " + err.message });
    }
});

app.listen(3001, () => console.log('[SIGEP] Servidor Rodando na 3001'));

