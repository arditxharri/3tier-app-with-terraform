module.exports = Object.freeze({
    DB_HOST: process.env.DB_HOST || 'localhost',
    DB_USER: process.env.DB_USER || 'admin',
    DB_PWD:  process.env.DB_PASS || 'yourpassword',
    DB_DATABASE: process.env.DB_NAME || 'webappdb'
});
