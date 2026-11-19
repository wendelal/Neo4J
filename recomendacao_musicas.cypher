// =====================================================================
// DESAFIO: Sistema de Recomendação de Músicas com Grafos (Neo4j/Cypher)
// =====================================================================
// Modelo:
//   (:Usuario)-[:ESCUTOU {vezes, ultima_vez}]->(:Musica)
//   (:Usuario)-[:CURTIU {em}]->(:Musica)
//   (:Usuario)-[:SEGUE {desde}]->(:Artista)
//   (:Usuario)-[:SEGUE {desde}]->(:Usuario)
//   (:Musica)-[:INTERPRETADA_POR]->(:Artista)
//   (:Musica)-[:PERTENCE_A]->(:Genero)
// =====================================================================


// ---------------------------------------------------------------------
// 0. LIMPEZA (opcional) — CUIDADO: apaga TODO o banco!
// ---------------------------------------------------------------------
// MATCH (n) DETACH DELETE n;


// ---------------------------------------------------------------------
// 1. CONSTRAINTS — garantem IDs únicos e evitam nós duplicados
// ---------------------------------------------------------------------
CREATE CONSTRAINT usuario_id IF NOT EXISTS FOR (u:Usuario) REQUIRE u.id IS UNIQUE;
CREATE CONSTRAINT musica_id  IF NOT EXISTS FOR (m:Musica)  REQUIRE m.id IS UNIQUE;
CREATE CONSTRAINT artista_id IF NOT EXISTS FOR (a:Artista) REQUIRE a.id IS UNIQUE;
CREATE CONSTRAINT genero_id  IF NOT EXISTS FOR (g:Genero)  REQUIRE g.id IS UNIQUE;


// ---------------------------------------------------------------------
// 2. NÓS — usamos MERGE para não duplicar se o script rodar 2 vezes
// ---------------------------------------------------------------------

// Gêneros
UNWIND [
  {id: 'g1', nome: 'Rock'},
  {id: 'g2', nome: 'Pop'},
  {id: 'g3', nome: 'Sertanejo'},
  {id: 'g4', nome: 'Eletrônica'}
] AS row
MERGE (g:Genero {id: row.id})
SET g.nome = row.nome;

// Artistas
UNWIND [
  {id: 'a1', nome: 'Banda Horizonte', pais: 'Brasil'},
  {id: 'a2', nome: 'Luna Vega',       pais: 'Brasil'},
  {id: 'a3', nome: 'Dupla Cerrado',   pais: 'Brasil'},
  {id: 'a4', nome: 'DJ Pulso',        pais: 'Brasil'},
  {id: 'a5', nome: 'Os Andarilhos',   pais: 'Brasil'},
  {id: 'a6', nome: 'Clara Mar',       pais: 'Brasil'}
] AS row
MERGE (a:Artista {id: row.id})
SET a.nome = row.nome, a.pais = row.pais;

// Músicas (já ligadas ao artista e ao gênero)
UNWIND [
  {id: 'm1',  titulo: 'Estrada Aberta',      ano: 2021, duracao: 214, artista: 'a1', genero: 'g1'},
  {id: 'm2',  titulo: 'Céu de Concreto',     ano: 2022, duracao: 198, artista: 'a1', genero: 'g1'},
  {id: 'm3',  titulo: 'Noite Neon',          ano: 2023, duracao: 185, artista: 'a2', genero: 'g2'},
  {id: 'm4',  titulo: 'Brilho',              ano: 2024, duracao: 176, artista: 'a2', genero: 'g2'},
  {id: 'm5',  titulo: 'Poeira Vermelha',     ano: 2020, duracao: 205, artista: 'a3', genero: 'g3'},
  {id: 'm6',  titulo: 'Saudade do Interior', ano: 2023, duracao: 221, artista: 'a3', genero: 'g3'},
  {id: 'm7',  titulo: 'Batida Solar',        ano: 2024, duracao: 240, artista: 'a4', genero: 'g4'},
  {id: 'm8',  titulo: 'Frequência',          ano: 2025, duracao: 233, artista: 'a4', genero: 'g4'},
  {id: 'm9',  titulo: 'Caminhos',            ano: 2022, duracao: 207, artista: 'a5', genero: 'g1'},
  {id: 'm10', titulo: 'Fogo Lento',          ano: 2025, duracao: 219, artista: 'a5', genero: 'g1'},
  {id: 'm11', titulo: 'Maré',                ano: 2024, duracao: 190, artista: 'a6', genero: 'g2'},
  {id: 'm12', titulo: 'Vento Sul',           ano: 2025, duracao: 182, artista: 'a6', genero: 'g2'}
] AS row
MERGE (m:Musica {id: row.id})
SET m.titulo = row.titulo, m.ano = row.ano, m.duracao_seg = row.duracao
WITH m, row
MATCH (a:Artista {id: row.artista}), (g:Genero {id: row.genero})
MERGE (m)-[:INTERPRETADA_POR]->(a)
MERGE (m)-[:PERTENCE_A]->(g);

// Usuários
UNWIND [
  {id: 'u1', nome: 'Ana',   cidade: 'Palmas'},
  {id: 'u2', nome: 'Bruno', cidade: 'Araguaína'},
  {id: 'u3', nome: 'Carla', cidade: 'Gurupi'},
  {id: 'u4', nome: 'Diego', cidade: 'Palmas'},
  {id: 'u5', nome: 'Elisa', cidade: 'Porto Nacional'}
] AS row
MERGE (u:Usuario {id: row.id})
SET u.nome = row.nome, u.cidade = row.cidade;


// ---------------------------------------------------------------------
// 3. INTERAÇÕES (arestas com propriedades)
// ---------------------------------------------------------------------

// ESCUTOU — quantas vezes e quando foi a última
UNWIND [
  {u: 'u1', m: 'm1',  vezes: 15, ultima: '2026-11-10'},
  {u: 'u1', m: 'm2',  vezes: 8,  ultima: '2026-11-08'},
  {u: 'u1', m: 'm3',  vezes: 4,  ultima: '2026-10-30'},
  {u: 'u2', m: 'm1',  vezes: 10, ultima: '2026-11-12'},
  {u: 'u2', m: 'm9',  vezes: 12, ultima: '2026-11-15'},
  {u: 'u2', m: 'm10', vezes: 6,  ultima: '2026-11-14'},
  {u: 'u3', m: 'm3',  vezes: 20, ultima: '2026-11-16'},
  {u: 'u3', m: 'm4',  vezes: 9,  ultima: '2026-11-11'},
  {u: 'u3', m: 'm11', vezes: 7,  ultima: '2026-11-09'},
  {u: 'u4', m: 'm5',  vezes: 18, ultima: '2026-11-17'},
  {u: 'u4', m: 'm6',  vezes: 11, ultima: '2026-11-13'},
  {u: 'u4', m: 'm1',  vezes: 3,  ultima: '2026-10-25'},
  {u: 'u5', m: 'm7',  vezes: 25, ultima: '2026-11-18'},
  {u: 'u5', m: 'm8',  vezes: 14, ultima: '2026-11-15'},
  {u: 'u5', m: 'm3',  vezes: 5,  ultima: '2026-11-01'}
] AS row
MATCH (u:Usuario {id: row.u}), (m:Musica {id: row.m})
MERGE (u)-[e:ESCUTOU]->(m)
SET e.vezes = row.vezes, e.ultima_vez = date(row.ultima);

// CURTIU — data da curtida
UNWIND [
  {u: 'u1', m: 'm1',  em: '2026-09-02'},
  {u: 'u1', m: 'm3',  em: '2026-10-20'},
  {u: 'u2', m: 'm1',  em: '2026-08-15'},
  {u: 'u2', m: 'm9',  em: '2026-09-10'},
  {u: 'u2', m: 'm10', em: '2026-11-01'},
  {u: 'u3', m: 'm3',  em: '2026-07-22'},
  {u: 'u3', m: 'm4',  em: '2026-09-30'},
  {u: 'u3', m: 'm11', em: '2026-10-05'},
  {u: 'u4', m: 'm5',  em: '2026-06-18'},
  {u: 'u4', m: 'm6',  em: '2026-08-27'},
  {u: 'u5', m: 'm7',  em: '2026-05-11'},
  {u: 'u5', m: 'm8',  em: '2026-10-14'},
  {u: 'u5', m: 'm3',  em: '2026-10-28'}
] AS row
MATCH (u:Usuario {id: row.u}), (m:Musica {id: row.m})
MERGE (u)-[c:CURTIU]->(m)
SET c.em = date(row.em);

// SEGUE — usuário segue artista
UNWIND [
  {u: 'u1', a: 'a1', desde: '2025-03-10'},
  {u: 'u1', a: 'a5', desde: '2026-01-05'},
  {u: 'u2', a: 'a5', desde: '2025-07-19'},
  {u: 'u3', a: 'a2', desde: '2024-11-02'},
  {u: 'u3', a: 'a6', desde: '2025-12-12'},
  {u: 'u4', a: 'a3', desde: '2023-05-30'},
  {u: 'u5', a: 'a4', desde: '2024-02-14'}
] AS row
MATCH (u:Usuario {id: row.u}), (a:Artista {id: row.a})
MERGE (u)-[s:SEGUE]->(a)
SET s.desde = date(row.desde);

// SEGUE — usuário segue outro usuário (lado social)
UNWIND [
  {de: 'u1', para: 'u2', desde: '2025-06-01'},
  {de: 'u2', para: 'u1', desde: '2025-06-02'},
  {de: 'u3', para: 'u5', desde: '2026-02-20'},
  {de: 'u4', para: 'u1', desde: '2026-04-11'}
] AS row
MATCH (a:Usuario {id: row.de}), (b:Usuario {id: row.para})
MERGE (a)-[s:SEGUE]->(b)
SET s.desde = date(row.desde);


// ---------------------------------------------------------------------
// 4. CONSULTAS DE EXPLORAÇÃO
// ---------------------------------------------------------------------

// 4.1 Visualizar o grafo inteiro
MATCH (n)-[r]->(m) RETURN n, r, m;

// 4.2 Perfil de escuta da Ana (músicas mais ouvidas)
MATCH (u:Usuario {nome: 'Ana'})-[e:ESCUTOU]->(m:Musica)-[:INTERPRETADA_POR]->(a:Artista)
RETURN m.titulo AS musica, a.nome AS artista, e.vezes AS vezes
ORDER BY vezes DESC;

// 4.3 Músicas mais populares da plataforma (total de reproduções)
MATCH (:Usuario)-[e:ESCUTOU]->(m:Musica)
RETURN m.titulo AS musica, sum(e.vezes) AS total_reproducoes
ORDER BY total_reproducoes DESC
LIMIT 5;


// ---------------------------------------------------------------------
// 5. CONSULTAS DE RECOMENDAÇÃO (para a usuária u1 = Ana)
// ---------------------------------------------------------------------

// 5.1 FILTRAGEM COLABORATIVA
// "Quem curtiu as mesmas músicas que você também curtiu..."
MATCH (eu:Usuario {id: 'u1'})-[:CURTIU]->(:Musica)<-[:CURTIU]-(outro:Usuario)-[:CURTIU]->(rec:Musica)
WHERE outro <> eu
  AND NOT EXISTS { (eu)-[:ESCUTOU|CURTIU]->(rec) }
RETURN rec.titulo AS musica,
       count(DISTINCT outro) AS usuarios_parecidos,
       collect(DISTINCT outro.nome) AS indicado_por
ORDER BY usuarios_parecidos DESC, musica
LIMIT 5;

// 5.2 POR GÊNERO FAVORITO (baseada em conteúdo)
// Gêneros mais ouvidos (somando e.vezes) -> músicas desse gênero que ainda não ouviu
MATCH (eu:Usuario {id: 'u1'})-[e:ESCUTOU]->(:Musica)-[:PERTENCE_A]->(g:Genero)
WITH eu, g, sum(e.vezes) AS afinidade
MATCH (g)<-[:PERTENCE_A]-(rec:Musica)-[:INTERPRETADA_POR]->(a:Artista)
WHERE NOT EXISTS { (eu)-[:ESCUTOU|CURTIU]->(rec) }
RETURN rec.titulo AS musica, a.nome AS artista, g.nome AS genero, afinidade
ORDER BY afinidade DESC, musica
LIMIT 5;

// 5.3 ARTISTAS QUE VOCÊ SEGUE
// Músicas dos artistas seguidos que ainda não foram ouvidas
MATCH (eu:Usuario {id: 'u1'})-[:SEGUE]->(a:Artista)<-[:INTERPRETADA_POR]-(rec:Musica)
WHERE NOT EXISTS { (eu)-[:ESCUTOU|CURTIU]->(rec) }
RETURN rec.titulo AS musica, a.nome AS artista
ORDER BY musica;

// 5.4 SOCIAL — o que as pessoas que você segue estão ouvindo
MATCH (eu:Usuario {id: 'u1'})-[:SEGUE]->(amigo:Usuario)-[e:ESCUTOU]->(rec:Musica)
WHERE NOT EXISTS { (eu)-[:ESCUTOU|CURTIU]->(rec) }
RETURN rec.titulo AS musica, amigo.nome AS amigo, e.vezes AS vezes_que_ouviu
ORDER BY vezes_que_ouviu DESC;

// 5.5 RECOMENDAÇÃO HÍBRIDA (ranking final com pontuação)
// Peso 3 = usuários parecidos curtiram | Peso 2 = artista seguido | Peso 1 = mesmo gênero
MATCH (eu:Usuario {id: 'u1'})
CALL {
  WITH eu
  MATCH (eu)-[:CURTIU]->(:Musica)<-[:CURTIU]-(outro:Usuario)-[:CURTIU]->(rec:Musica)
  WHERE outro <> eu
  RETURN rec, 3 AS pontos
  UNION ALL
  WITH eu
  MATCH (eu)-[:SEGUE]->(:Artista)<-[:INTERPRETADA_POR]-(rec:Musica)
  RETURN rec, 2 AS pontos
  UNION ALL
  WITH eu
  MATCH (eu)-[:ESCUTOU]->(:Musica)-[:PERTENCE_A]->(:Genero)<-[:PERTENCE_A]-(rec:Musica)
  RETURN rec, 1 AS pontos
}
WITH eu, rec, sum(pontos) AS score
WHERE NOT EXISTS { (eu)-[:ESCUTOU|CURTIU]->(rec) }
MATCH (rec)-[:INTERPRETADA_POR]->(a:Artista)
RETURN rec.titulo AS musica, a.nome AS artista, score
ORDER BY score DESC, musica
LIMIT 5;
