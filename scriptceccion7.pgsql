-- 1. Borrar tablas si ya existen para evitar errores
DROP TABLE IF EXISTS wave_rewards;
DROP TABLE IF EXISTS zombie_wave_stats;

-- 2. Crear tabla zombie_wave_stats
CREATE TABLE zombie_wave_stats (
    wave_id SERIAL PRIMARY KEY,
    wave_number INT NOT NULL,
    zombies_spawned INT NOT NULL,
    boss_present BOOLEAN NOT NULL,
    time_limit INT NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL
);

-- 3. Insertar datos en zombie_wave_stats
INSERT INTO zombie_wave_stats (wave_number, zombies_spawned, boss_present, time_limit, difficulty_level) VALUES
(1, 15, false, 60, 'Easy'),
(2, 20, false, 75, 'Easy'),
(3, 25, false, 80, 'Normal'),
(4, 30, true, 90, 'Normal'),
(5, 40, false, 100, 'Hard'),
(6, 50, true, 110, 'Hard'),
(7, 60, false, 120, 'Hard'),
(8, 70, true, 130, 'Very Hard'),
(9, 80, false, 140, 'Very Hard'),
(10, 100, true, 180, 'Extreme');

-- 4. Crear tabla wave_rewards
CREATE TABLE wave_rewards (
    reward_id SERIAL PRIMARY KEY,
    wave_number INT NOT NULL,
    reward_name VARCHAR(50) NOT NULL
);

-- 5. Insertar datos en wave_rewards
INSERT INTO wave_rewards (wave_number, reward_name) VALUES
(1, 'Ammo Pack'),
(2, 'Health Kit'),
(3, 'Armor Upgrade'),
(4, 'Shotgun Unlock'),
(5, 'Sniper Ammo'),
(6, 'Medkit Pro'),
(7, 'Flamethrower'),
(8, 'Rocket Launcher'),
(9, 'Grenade Pack'),
(10, 'Laser Rifle');

-- 6. Consulta con la sintaxis solicitada (NO se cambia nada)
SELECT zombie_wave_stats.wave_id, wave_rewards.reward_id
FROM zombie_wave_stats, wave_rewards
WHERE zombie_wave_stats.wave_number = wave_rewards.wave_number;


SELECT zombie_wave_stats.wave_id, wave_rewards.reward_id
FROM zombie_wave_stats, wave_rewards
WHERE zombie_wave_stats.wave_number = wave_rewards.wave_number;

SELECT zombie_wave_stats.wave_number, zombie_wave_stats.difficulty_level, wave_rewards.reward_name
FROM zombie_wave_stats, wave_rewards
WHERE zombie_wave_stats.wave_number = wave_rewards.wave_number;


SELECT zombie_wave_stats.difficulty_level, wave_rewards.reward_name
FROM zombie_wave_stats, wave_rewards
WHERE zombie_wave_stats.wave_number = wave_rewards.wave_number;

SELECT zombie_wave_stats.difficulty_level, wave_rewards.reward_name
FROM zombie_wave_stats, wave_rewards;

SELECT z.difficulty_level, z.wave_id, w.reward_name
FROM zombie_wave_stats z, wave_rewards w
WHERE z.wave_number = w.wave_number
AND z.wave_number = 8;

-- 1. Crear tabla wave_locations
DROP TABLE IF EXISTS wave_locations;
CREATE TABLE wave_locations (
    location_id SERIAL PRIMARY KEY,
    city VARCHAR(50) NOT NULL
);

-- 2. Insertar ubicaciones de ejemplo
INSERT INTO wave_locations (city) VALUES
('Graveyard'),
('Abandoned City'),
('Research Lab'),
('Military Base'),
('Desert Outpost');

-- 3. Modificar tabla wave_rewards para tener location_id
ALTER TABLE wave_rewards ADD COLUMN location_id INT;
UPDATE wave_rewards
SET location_id = ((reward_id - 1) % 5) + 1;  -- Asignar ubicaciones aleatorias

-- 4. Consulta adaptada (misma estructura que la tuya)
SELECT z.difficulty_level, l.city
FROM zombie_wave_stats z, wave_rewards w,
     wave_locations l
WHERE z.wave_number = w.wave_number
AND w.location_id = l.location_id;


