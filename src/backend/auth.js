const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Pega o token após o 'Bearer'

    if (!token) return res.status(403).json({ erro: "Acesso negado. Token não fornecido." });

    try {
        const decodificado = jwt.verify(token, process.env.JWT_SECRET);
        
        // Critério de Aceite: Verificar se é ADMIN ou DIRETOR
        if (decodificado.role !== 'ADMIN' && decodificado.role !== 'DIRETOR') {
            return res.status(403).json({ erro: "Acesso negado. Apenas administradores podem cadastrar funcionários." });
        }

        req.usuarioLogado = decodificado;
        next();
    } catch (err) {
        res.status(401).json({ erro: "Token inválido ou expirado." });
    }
};
