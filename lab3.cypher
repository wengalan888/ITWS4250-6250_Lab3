// lab3
// clear
MATCH (n) DETACH DELETE n;

// constraints
CREATE CONSTRAINT disease_name IF NOT EXISTS FOR (d:Disease) REQUIRE d.name IS UNIQUE;
CREATE CONSTRAINT country_id IF NOT EXISTS FOR (c:Country) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT state_id IF NOT EXISTS FOR (s:State) REQUIRE s.id IS UNIQUE;
CREATE CONSTRAINT city_id IF NOT EXISTS FOR (c:City) REQUIRE c.id IS UNIQUE;

// diseases
MERGE (d:Disease {name: 'Malaria'})
 SET d.pathogen = 'Plasmodium parasite', d.vector = 'Anopheles mosquito';
MERGE (d:Disease {name: 'Dengue'})
 SET d.pathogen = 'Dengue virus', d.vector = 'Aedes mosquito';
MERGE (d:Disease {name: 'Chikungunya'})
 SET d.pathogen = 'Chikungunya virus', d.vector = 'Aedes mosquito';
MERGE (d:Disease {name: 'Zika'})
 SET d.pathogen = 'Zika virus', d.vector = 'Aedes mosquito';

// countries
MERGE (c:Country {id: 'IN'}) SET c.name = 'India', c.admin_level = 0;
MERGE (c:Country {id: 'BR'}) SET c.name = 'Brazil', c.admin_level = 0;
MERGE (c:Country {id: 'NG'}) SET c.name = 'Nigeria', c.admin_level = 0;

// states and link to countries
MATCH (c:Country {id: 'IN'})
MERGE (s:State {id: 'IN-TN'}) SET s.name = 'Tamil Nadu', s.admin_level = 1
MERGE (s)-[:IS_PART_OF]->(c);
MATCH (c:Country {id: 'BR'})
MERGE (s:State {id: 'BR-SP'}) SET s.name = 'São Paulo', s.admin_level = 1
MERGE (s)-[:IS_PART_OF]->(c);
MATCH (c:Country {id: 'BR'})
MERGE (s:State {id: 'BR-RJ'}) SET s.name = 'Rio de Janeiro', s.admin_level = 1
MERGE (s)-[:IS_PART_OF]->(c);
MATCH (c:Country {id: 'NG'})
MERGE (s:State {id: 'NG-LA'}) SET s.name = 'Lagos', s.admin_level = 1
MERGE (s)-[:IS_PART_OF]->(c);

// cities
MATCH (s:State {id: 'IN-TN'})
MERGE (c:City {id: 'IN-TN-CHE'}) SET c.name = 'Chennai', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);
MATCH (s:State {id: 'IN-TN'})
MERGE (c:City {id: 'IN-TN-CBE'}) SET c.name = 'Coimbatore', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);
MATCH (s:State {id: 'BR-SP'})
MERGE (c:City {id: 'BR-SP-SAO'}) SET c.name = 'São Paulo', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);
MATCH (s:State {id: 'BR-RJ'})
MERGE (c:City {id: 'BR-RJ-RIO'}) SET c.name = 'Rio de Janeiro', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);
MATCH (s:State {id: 'NG-LA'})
MERGE (c:City {id: 'NG-LA-IKJ'}) SET c.name = 'Ikeja', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);

// case reports
MATCH (c:City {id: 'IN-TN-CHE'}), (d:Disease {name: 'Dengue'})
MERGE (c)-[r:HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 500;
MATCH (c:City {id: 'IN-TN-CHE'}), (d:Disease {name: 'Malaria'})
MERGE (c)-[r:HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 180;
MATCH (c:City {id: 'IN-TN-CBE'}), (d:Disease {name: 'Malaria'})
MERGE (c)-[r:HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 250;
MATCH (c:City {id: 'BR-SP-SAO'}), (d:Disease {name: 'Chikungunya'})
MERGE (c)-[r:HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 120;
MATCH (c:City {id: 'BR-SP-SAO'}), (d:Disease {name: 'Dengue'})
MERGE (c)-[r:HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 650;
MATCH (c:City {id: 'BR-RJ-RIO'}), (d:Disease {name: 'Dengue'})
MERGE (c)-[r:HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 800;
MATCH (c:City {id: 'NG-LA-IKJ'}), (d:Disease {name: 'Malaria'})
MERGE (c)-[r:HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 1500;
MATCH (c:City {id: 'NG-LA-IKJ'}), (d:Disease {name: 'Dengue'})
MERGE (c)-[r:HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 90;


// q1
MATCH
  (country:Country)<-[:IS_PART_OF*1..2]-(city:City)-[r:HAS_CASES_OF]->(:Disease)
RETURN country.name AS country, sum(r.case_count) AS total_cases
ORDER BY total_cases DESC;

// q2
MATCH
  (disease:Disease)<-[r:HAS_CASES_OF]-
  (city:City)-[:IS_PART_OF*1..2]->
  (country:Country)
RETURN
  disease.name AS disease,
  count(DISTINCT country) AS num_country,
  collect(DISTINCT country.name) AS countries,
  sum(r.case_count) AS total_cases
ORDER BY total_cases DESC;

// q3
MATCH
  (disease:Disease)<-[r:HAS_CASES_OF]-
  (city:City)-[:IS_PART_OF]->
  (state:State)-[:IS_PART_OF]->
  (country:Country)
RETURN
  city.name AS city,
  state.name AS state,
  country.name AS country,
  disease.name AS disease,
  r.case_count AS case_count
ORDER BY case_count DESC
LIMIT 1;

// q4
MATCH
  (disease:Disease)<-[r:HAS_CASES_OF]-
  (city:City)-[:IS_PART_OF*1..2]->
  (country:Country)
RETURN
  country.name AS country,
  sum(
    CASE
      WHEN disease.name = 'Dengue' THEN r.case_count
      ELSE 0
    END) AS dengue_cases,
  sum(r.case_count) AS all_cases,
  round(
    100.0 *
    sum(
      CASE
        WHEN disease.name = 'Dengue' THEN r.case_count
        ELSE 0
      END) /
    sum(r.case_count),
    1
  ) AS dengue_percentage
ORDER BY dengue_percentage DESC;