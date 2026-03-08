const bcrypt = require('bcrypt');
const saltRounds = 10;

const security = {
    gerarHash: async (senha) => await bcrypt.hash(senha, saltRounds),
    compararSenha: async (senha, hash) => await bcrypt.compare(senha, hash)
};

module.exports = security;
