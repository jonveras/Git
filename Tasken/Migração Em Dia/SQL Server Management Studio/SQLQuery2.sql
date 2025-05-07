
SELECT TOP 10 
a.NUMACOCON_ACO,
b.COD_ACORDOCONJUNTO,
*
FROM CAD_ACO A (NOLOCK)
JOIN CAD_ACORDOCONJUNTO B (NOLOCK) ON A.NUMACOCON_ACO = B.COD_ACORDOCONJUNTO
WHERE A.COD_STAC = 3 
ORDER BY A.DTACORDO_ACO DESC

SELECT * FROM API.LOG_REQUISICOES WHERE ID = 154069
SELECT * FROM API.LOG_REQUISICOES_EXTERNAS WHERE ID_LOG_REQUISICAO = 89811

SELECT * FROM CAD_DEVF WHERE COBRANCA_FIN = 0 AND STATCONT_FIN = 0 AND COD_CLI = 136


SELECT * FROM CAD_CAR WHERE CONTROLE_CAR LIKE '%SEMPARAR%'

SELECT 
                                Nome          = A.NOME_DEV,
                                NomeSocial    = A.NOME_SOCIAL,
                                Mae           = A.MAE_DEV,
                                Empresa       = RTRIM(A.EMPRESA_DEV),
                                CpfCnpj       = RTRIM(A.CPF_DEV),
                                RG            = A.RG_DEV,
                                DataExpedicao = A.EXP_DEV,
                                Pai           = A.PAI_DEV,
                                Profissao     = RTRIM(A.PROFISSAO_DEV),
                                Nascimento    = A.DTNASC_DEV,
                                Orgao         = A.ORG_DEV,
                                EstadoCivil   = RTRIM(B.DESC_ESTCIV),
                                Sexo          = RTRIM(C.DESC_SEXO),
                                ConjugeCPF    = RTRIM(A.CONJCPF_DEV),
                                ConjugeNome   = A.CONJNOME_DEV,
                                SenhaDEBT     = A.VIRCOBWEBSENHA_DEV,
                                DDD           = RTRIM(D.DDD_TEL),
                                Telefone      = D.TEL_TEL,
                                Email         = RTRIM(E.DESC_DEVMAIL),
                                DataNascimento= RTRIM(A.NASC_DEV)
                                FROM 
                                CAD_DEV(NOLOCK) AS A
                                LEFT JOIN 
                                    CAD_ESTCIV(NOLOCK) AS B ON A.COD_ESTCIV = B.COD_ESTCIV
                                LEFT JOIN 
                                    CAD_SEXO(NOLOCK) AS C ON A.COD_SEXO = C.COD_SEXO
                                LEFT JOIN 
                                    CAD_DEVT(NOLOCK) AS D ON D.CPF_DEV = A.CPF_DEV
                                LEFT JOIN 
                                    CAD_DEVMAIL(NOLOCK) AS E ON A.CPF_DEV = E.CPF_DEV AND (E.COD_REF IS NULL OR E.COD_REF = 0)
                                WHERE 
                                    A.CPF_DEV = '22434264808' ORDER BY E.DESC_DEVMAIL DESC, D.PERC_TEL DESC

sELECT * FROM API.BASES