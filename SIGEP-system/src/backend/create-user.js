const pool = require('./db');

async function createUser() {
    const senhaHash = '$2b$10$szAlXEaQDxgG26Y2hcpL9uwVWrezqunAMB4GXUdi0jZxJ.d0Unu52';
    
    const result = await pool.query(
        `INSERT INTO public.usuarios 
        (matricula, senha, nome_completo, cpf, data_nascimento, estado_civil, email_funcional, cargo, role) 
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
        ON CONFLICT (matricula) DO UPDATE SET senha = $2
        RETURNING id, nome_completo, role`,
        [
            '52934', 
            senhaHash, 
            'henriquelima', 
            '12345678901', 
            '1990-01-01', 
            'SOLTEIRO', 
            'henrique@sigep.gov.br', 
            'ADMINISTRADOR', 
            'ADMIN'
        ]
    );

    console.log('Usuário criado/atualizado:', result.rows[0]);
    process.exit(0);
}

createUser().catch(err => {
    console.error('Erro:', err.message);
    process.exit(1);
});
