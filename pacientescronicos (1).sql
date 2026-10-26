-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 26-10-2026 a las 00:15:30
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `pacientescronicos`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `cambiar_estado_usuario` (IN `p_id` BIGINT, IN `p_estado` ENUM('Activo','Inactivo'))   BEGIN
                IF EXISTS (SELECT 1 FROM usuarios WHERE id = p_id) THEN
                    UPDATE usuarios
                    SET estado = p_estado,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = p_id;
                ELSE
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'El usuario no existe';
                END IF;
            END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_paciente` (IN `p_primer_nombre` VARCHAR(50), IN `p_segundo_nombre` VARCHAR(50), IN `p_apellido_paterno` VARCHAR(50), IN `p_apellido_materno` VARCHAR(50), IN `p_email` VARCHAR(50), IN `p_password` VARCHAR(255), IN `p_medico_id` BIGINT UNSIGNED, IN `p_fecha_nacimiento` DATE, IN `p_telefono_emergencia` VARCHAR(20), IN `p_sexo` VARCHAR(10), IN `p_diagnostico_principal` VARCHAR(255), IN `p_nivel_riesgo` VARCHAR(10))   BEGIN
                DECLARE v_usuario_id BIGINT UNSIGNED;

                INSERT INTO usuarios (
                    primer_nombre,
                    segundo_nombre,
                    apellido_paterno,
                    apellido_materno,
                    rol_id,
                    email,
                    password
                )
                VALUES (
                    p_primer_nombre,
                    NULLIF(TRIM(p_segundo_nombre), ''),
                    p_apellido_paterno,
                    p_apellido_materno,
                    3,
                    p_email,
                    p_password
                );

                SET v_usuario_id = LAST_INSERT_ID();

                INSERT INTO pacientes (
                    usuario_id,
                    medico_id,
                    fecha_nacimiento,
                    telefono_emergencia,
                    sexo,
                    estatura,
                    diagnostico_principal,
                    nivel_riesgo
                )
                VALUES (
                    v_usuario_id,
                    p_medico_id,
                    p_fecha_nacimiento,
                    p_telefono_emergencia,
                    p_sexo,
                    1.70,
                    p_diagnostico_principal,
                    p_nivel_riesgo
                );
            END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_medico` (IN `p_primer_nombre` VARCHAR(50), IN `p_segundo_nombre` VARCHAR(50), IN `p_apellido_paterno` VARCHAR(50), IN `p_apellido_materno` VARCHAR(50), IN `p_rol_id` BIGINT, IN `p_email` VARCHAR(50), IN `p_password` VARCHAR(255), IN `p_cedula_profesional` VARCHAR(30), IN `p_especialidad` VARCHAR(100), IN `p_telefono` VARCHAR(10), IN `p_consultorio` VARCHAR(50), IN `p_turno` ENUM('Matutino','Vespertino','Nocturno','Mixto'), IN `p_observaciones` TEXT)   BEGIN
                DECLARE v_usuario_id BIGINT;

                INSERT INTO usuarios (
                    primer_nombre,
                    segundo_nombre,
                    apellido_paterno,
                    apellido_materno,
                    rol_id,
                    email,
                    password
                )
                VALUES (
                    p_primer_nombre,
                    NULLIF(TRIM(p_segundo_nombre), ''),
                    p_apellido_paterno,
                    p_apellido_materno,
                    p_rol_id,
                    p_email,
                    p_password
                );

                SET v_usuario_id = LAST_INSERT_ID();

                INSERT INTO medicos (
                    usuario_id,
                    cedula_profesional,
                    especialidad,
                    telefono,
                    consultorio,
                    turno,
                    observaciones
                )
                VALUES (
                    v_usuario_id,
                    p_cedula_profesional,
                    p_especialidad,
                    p_telefono,
                    NULLIF(TRIM(p_consultorio), ''),
                    p_turno,
                    NULLIF(TRIM(p_observaciones), '')
                );
            END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `cache`
--

INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES
('laravel-cache-admin@gmail.com|127.0.0.1', 'i:2;', 1792622844),
('laravel-cache-admin@gmail.com|127.0.0.1:timer', 'i:1792622844;', 1792622844);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medicos`
--

CREATE TABLE `medicos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `usuario_id` bigint(20) UNSIGNED NOT NULL,
  `cedula_profesional` varchar(30) NOT NULL,
  `especialidad` varchar(100) NOT NULL,
  `telefono` varchar(10) NOT NULL,
  `consultorio` varchar(50) DEFAULT NULL,
  `turno` enum('Matutino','Vespertino','Nocturno','Mixto') NOT NULL DEFAULT 'Matutino',
  `observaciones` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `medicos`
--

INSERT INTO `medicos` (`id`, `usuario_id`, `cedula_profesional`, `especialidad`, `telefono`, `consultorio`, `turno`, `observaciones`, `created_at`, `updated_at`) VALUES
(1, 2, 'MED-984321', 'Medicina Interna y Cardiología', '3121234567', 'Consultorio 204-B', 'Matutino', 'Especialista a cargo del programa de monitoreo crónico.', '2026-10-22 04:59:27', '2026-10-22 04:59:27'),
(2, 6, 'MED-EEJJFJFJFJ', 'Medicina interna cronica', '3141053971', 'Consultorio 204-B', 'Vespertino', 'KEJEJEJ', '2026-10-22 06:24:49', '2026-10-22 06:24:49');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metricas`
--

CREATE TABLE `metricas` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `unidad_medida` varchar(20) NOT NULL,
  `rango_min_normal` decimal(7,2) DEFAULT NULL,
  `rango_max_normal` decimal(7,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `metricas`
--

INSERT INTO `metricas` (`id`, `nombre`, `unidad_medida`, `rango_min_normal`, `rango_max_normal`, `created_at`, `updated_at`) VALUES
(1, 'Presión Arterial Sistólica', 'mmHg', 90.00, 120.00, '2026-10-22 04:59:25', '2026-10-21 22:59:25'),
(2, 'Presión Arterial Diastólica', 'mmHg', 60.00, 80.00, '2026-10-22 04:59:25', '2026-10-21 22:59:25'),
(3, 'Glucosa en Sangre', 'mg/dL', 70.00, 100.00, '2026-10-22 04:59:25', '2026-10-21 22:59:25'),
(4, 'Peso Corporal', 'kg', NULL, NULL, '2026-10-22 04:59:25', '2026-10-21 22:59:25'),
(5, 'Frecuencia Cardíaca', 'lpm', 60.00, 100.00, '2026-10-22 04:59:25', '2026-10-21 22:59:25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metricas_pacientes`
--

CREATE TABLE `metricas_pacientes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `paciente_id` bigint(20) UNSIGNED NOT NULL,
  `tipo_metrica_id` bigint(20) UNSIGNED NOT NULL,
  `valor` decimal(8,2) NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp(),
  `notas` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `metricas_pacientes`
--

INSERT INTO `metricas_pacientes` (`id`, `paciente_id`, `tipo_metrica_id`, `valor`, `fecha_registro`, `notas`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 134.00, '2026-10-19 22:59:58', 'Medición rutinaria en ayunas', '2026-10-22 04:59:58', '2026-10-21 22:59:58'),
(2, 1, 1, 134.00, '2026-10-20 22:59:58', 'Control vespertino', '2026-10-22 04:59:58', '2026-10-21 22:59:58'),
(3, 1, 1, 114.00, '2026-10-21 22:59:58', 'Registro matutino', '2026-10-22 04:59:58', '2026-10-21 22:59:58'),
(4, 2, 1, 143.00, '2026-10-19 22:59:58', 'Medición rutinaria en ayunas', '2026-10-22 04:59:58', '2026-10-21 22:59:58'),
(5, 2, 1, 133.00, '2026-10-20 22:59:58', 'Control vespertino', '2026-10-22 04:59:58', '2026-10-21 22:59:58'),
(6, 2, 1, 124.00, '2026-10-21 22:59:58', 'Registro matutino', '2026-10-22 04:59:58', '2026-10-21 22:59:58'),
(7, 3, 1, 139.00, '2026-10-19 22:59:59', 'Medición rutinaria en ayunas', '2026-10-22 04:59:59', '2026-10-21 22:59:59'),
(8, 3, 1, 131.00, '2026-10-20 22:59:59', 'Control vespertino', '2026-10-22 04:59:59', '2026-10-21 22:59:59'),
(9, 3, 1, 126.00, '2026-10-21 22:59:59', 'Registro matutino', '2026-10-22 04:59:59', '2026-10-21 22:59:59');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_05_03_222520_create_roles_table', 1),
(5, '2026_05_03_222521_create_usuarios_table', 1),
(6, '2026_05_03_222522_create_medicos_table', 1),
(7, '2026_05_03_222522_create_pacientes_table', 1),
(8, '2026_05_03_222523_create_metricas_table', 1),
(9, '2026_05_03_222524_create_metricas_pacientes_table', 1),
(10, '2026_05_03_222525_add_remember_token_to_usuarios_table', 2),
(11, '2026_05_03_222526_create_vistas_sql', 2),
(12, '2026_05_03_222527_create_procedimientos_sql', 2),
(13, '2026_10_22_025953_create_personal_access_tokens_table', 3),
(14, '2026_10_22_030219_make_medico_id_nullable_in_pacientes_table', 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pacientes`
--

CREATE TABLE `pacientes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `usuario_id` bigint(20) UNSIGNED NOT NULL,
  `medico_id` bigint(20) UNSIGNED DEFAULT NULL,
  `fecha_nacimiento` date NOT NULL,
  `telefono_emergencia` varchar(20) NOT NULL,
  `sexo` varchar(10) NOT NULL,
  `estatura` decimal(3,2) NOT NULL,
  `diagnostico_principal` varchar(255) NOT NULL,
  `nivel_riesgo` enum('Bajo','Medio','Alto') NOT NULL DEFAULT 'Bajo',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `pacientes`
--

INSERT INTO `pacientes` (`id`, `usuario_id`, `medico_id`, `fecha_nacimiento`, `telefono_emergencia`, `sexo`, `estatura`, `diagnostico_principal`, `nivel_riesgo`, `created_at`, `updated_at`) VALUES
(1, 3, 1, '1965-04-12', '3129876543', 'Masculino', 1.72, 'Diabetes Mellitus Tipo 2 e Hipertensión', 'Alto', '2026-10-22 04:59:27', '2026-10-22 04:59:27'),
(2, 4, 1, '1974-08-23', '3128765432', 'Femenino', 1.65, 'Hipertensión Arterial Primaria', 'Medio', '2026-10-22 04:59:58', '2026-10-22 08:34:46'),
(3, 5, 1, '1982-11-05', '3127654321', 'Masculino', 1.78, 'Asma Bronquial Crónica', 'Bajo', '2026-10-22 04:59:59', '2026-10-22 04:59:59'),
(9, 21, 1, '1996-01-04', '123456789', 'Masculino', 1.72, 'Hipertensión Arterial', 'Bajo', '2026-10-25 08:03:42', '2026-10-25 08:03:42'),
(10, 22, 1, '1996-01-30', '123456789', 'Masculino', 1.73, 'Hipertensión Arterial', 'Bajo', '2026-10-25 08:52:58', '2026-10-25 08:52:58');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `pacientes_estado`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `pacientes_estado` (
`id` bigint(20) unsigned
,`nombre_completo` varchar(101)
,`fecha_nacimiento` date
,`diagnostico_principal` varchar(255)
,`nivel_riesgo` enum('Bajo','Medio','Alto')
,`sexo` varchar(10)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id`, `nombre`, `descripcion`, `created_at`, `updated_at`) VALUES
(1, 'Administrador', 'Gestión integral de usuarios y configuración', '2026-10-22 04:59:25', '2026-10-21 22:59:25'),
(2, 'Médico', 'Consulta de métricas y seguimiento de pacientes', '2026-10-22 04:59:25', '2026-10-21 22:59:25'),
(3, 'Paciente', 'Registro de métricas personales y consulta de historial', '2026-10-22 04:59:25', '2026-10-21 22:59:25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('5yS3drsspiqcBMgK6aSGaOnc1anf6JZJXrpJDxrz', 1, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiSmQyOHJ6akdSd3Q3b3VKcHJaTWgwcXB4RkhZaHFKNzhjR2NnSnZ4NSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTt9', 1792630558),
('Dstg9WvfMSJddrRKiZNVRl5NKhENaF9uzB38UE1V', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiOUNPTUxUamRWWWZIbVpKQUhBeExnelpvSXFiQ0lBYWVBWUtOOVdqUiI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozNzoiaHR0cDovLzEyNy4wLjAuMTo4MDAwL21lZGljby9yZXBvcnRlcyI7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjI3OiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbG9naW4iO3M6NToicm91dGUiO3M6NToibG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1792702631),
('jzJ6tZVPcntx8tykJ3cIZzgpzLr9S2Sle1fwWPJR', 1, '127.0.0.1', 'Symfony', 'YTo0OntzOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToxO3M6NjoiX3Rva2VuIjtzOjQwOiI3eXYyRm1xVVBPVnNqbnEwaWtDTTg1RkpzblpQYUpxbkN4eEcwUFNtIjtzOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czoyMjoiaHR0cDovL2xvY2FsaG9zdC9hZG1pbiI7czo1OiJyb3V0ZSI7czoxNToiYWRtaW4uZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1792628471),
('sIuwXtv4pznykkws1ZfWBsxJC2whfCfNGmrbRKQs', 1, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiUFhpajRRMEV6aDlQTDA0WkQxRWdJenViWXUwam15QU5FY2VNT21PNSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9hZG1pbiI7czo1OiJyb3V0ZSI7czoxNToiYWRtaW4uZGFzaGJvYXJkIjt9czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTt9', 1792643530),
('TthhfOVplhEO1M20UKAbrG7O7yNAUiWgyw06pJto', 2, '127.0.0.1', 'Symfony', 'YTo0OntzOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToyO3M6NjoiX3Rva2VuIjtzOjQwOiJjMFF2Q1AzMnJ0bFFKVUMzWllWSjlhYU1lMDNFZkM2N2RUdUx5SWdhIjtzOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czozMzoiaHR0cDovL2xvY2FsaG9zdC9tZWRpY28vcGFjaWVudGVzIjtzOjU6InJvdXRlIjtzOjIyOiJtZWRpY28ucGFjaWVudGVzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1792629460),
('Z3AmLeiyT7WafHwXq2WbUFsSl4XJu3y4bzYYeXUw', 2, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoieWo0UjFsR1FESXZQTGxqVTdjZ0pUWXBEUktCcHdjeDVPZVdPZnUwNSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mzc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9tZWRpY28vcmVwb3J0ZXMiO3M6NToicm91dGUiO3M6MTU6Im1lZGljby5yZXBvcnRlcyI7fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjI7fQ==', 1792692654);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `total_pacientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `total_pacientes` (
`total` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `total_pacientes_estables`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `total_pacientes_estables` (
`total` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `total_pacientes_riesgo_alto`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `total_pacientes_riesgo_alto` (
`total` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `primer_nombre` varchar(50) NOT NULL,
  `segundo_nombre` varchar(50) DEFAULT NULL,
  `apellido_paterno` varchar(50) NOT NULL,
  `apellido_materno` varchar(50) NOT NULL,
  `rol_id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `estado` enum('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
  `ultimo_acceso` timestamp NULL DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `primer_nombre`, `segundo_nombre`, `apellido_paterno`, `apellido_materno`, `rol_id`, `email`, `password`, `estado`, `ultimo_acceso`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Administrador', NULL, 'General', 'CróniCare', 1, 'admin@cronicare.com', '$2y$12$RA9lfKQJyjs7In.kq77UxOGcN7lgUoJajQ9uKJgxjQ/ytm5ZpqiDi', 'Activo', '2026-10-22 07:09:26', 'mR6sWA0B4M5MlfR7UBIrQi5jurF7ECXBkp63mswO3thzAmIs3NJDQW5RfOCh', '2026-10-22 04:59:26', '2026-10-22 18:00:27'),
(2, 'Carlos', 'Eduardo', 'Hernández', 'Torres', 2, 'medico@cronicare.com', '$2y$12$23qhWQdDxkRr0292UBz3Zu.i4As1Dy/.ArEVb7qPhu3uN1Cxw/C4i', 'Activo', '2026-10-23 00:00:38', 'sXfnAmfAqgJs0r5oh5QLuSFy40czoojkvSwdgDBI7ew2Sgv1s572zA0qeOvz', '2026-10-22 04:59:27', '2026-10-23 00:00:38'),
(3, 'Juan', 'Carlos', 'Gómez', 'López', 3, 'juan.paciente@cronicare.com', '$2y$12$wJZbIIBgbnUPj1dWoSDTGeEuXRbCa0zZMVZfAJQMgCQjVkF9RPry2', 'Activo', NULL, NULL, '2026-10-22 04:59:27', '2026-10-22 04:59:27'),
(4, 'María', 'Fernanda', 'Ramírez', 'Castro', 3, 'maria.paciente@cronicare.com', '$2y$12$AxizoE10m4MjI2H1nOBf9ekj54fxAs3KxUxYPNjW1x0eJQwgbz8lu', 'Activo', NULL, NULL, '2026-10-22 04:59:58', '2026-10-22 04:59:58'),
(5, 'Roberto', NULL, 'Vargas', 'Mendoza', 3, 'roberto.paciente@cronicare.com', '$2y$12$Lpzg5.tkt4VQF2sGumK/7.HWtM0JqM0OfG.fiijBjl5Qs4gXFMtle', 'Activo', NULL, NULL, '2026-10-22 04:59:59', '2026-10-22 04:59:59'),
(6, 'Carlos', 'Eduardo', 'Mendoza E', 'Serrano', 2, 'doctor@cronico.com', '$2y$12$omjc.QCJwtofJRdVk/sMUeodT61TAxM/5FDBw4n2QQ7EXjj0pRs6m', 'Activo', NULL, NULL, '2026-10-22 06:24:49', '2026-10-22 06:24:49'),
(12, 'andres', NULL, 'manuel', '', 3, 'andres123@gmail.com', '$2y$12$SaNxMix1i6u6/o1SzIW9Aeei2iF4UM0ht.hSqL3uGtwBc7fakayk.', 'Activo', NULL, NULL, '2026-10-23 04:43:28', '2026-10-23 04:43:28'),
(13, 'jose', NULL, 'torres', '', 3, 'josetorres@gmail.com', '$2y$12$73OPcB1PxC9bcDGueO3iDOA66OKP.NGMfbwqBUHz.49r7BNoqpOHe', 'Activo', NULL, NULL, '2026-10-23 04:49:34', '2026-10-23 04:49:34'),
(14, 'joseph', NULL, 'towers', '', 3, 'towers123@gmail.com', '$2y$12$PqfxBy9e.CXe0ksoMHrhNOi4c4JQdY1HL9FlzQRn654ML23IOLvCi', 'Activo', NULL, NULL, '2026-10-25 07:34:49', '2026-10-25 07:34:49'),
(15, 'jaime', NULL, 'juan', 'parra', 3, 'jjlerma@gmail.com', '$2y$12$M9x9DMLVODHk3wOTJ884deV92CB95rl.Qx8qQuXdwutTbnwfgtTAq', 'Activo', NULL, NULL, '2026-10-25 07:38:36', '2026-10-25 07:38:36'),
(21, 'luis', NULL, 'fernando', 'mendoza', 3, 'luis123@gmail.com', '$2y$12$POPWE19SP0u/XBYnEEvoP.Is..Ap8CCtgBq2CudJIAr3j4EyoRDue', 'Activo', NULL, NULL, '2026-10-25 08:03:42', '2026-10-25 08:03:42'),
(22, 'ricardo', 'gabriel', 'gregorio', 'barajas', 3, 'gregorio123@gmail.com', '$2y$12$kv5Xhhri2JblE2qwxkWLHOLMIKgYuvlYMTS9/UBz9CHVVl39Z57i.', 'Activo', NULL, NULL, '2026-10-25 08:52:58', '2026-10-25 08:52:58');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_medicos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_medicos` (
`usuario_id` bigint(20) unsigned
,`medico_id` bigint(20) unsigned
,`nombre_completo` varchar(101)
,`telefono` varchar(10)
,`email` varchar(50)
,`cedula_profesional` varchar(30)
,`especialidad` varchar(100)
,`estado` enum('Activo','Inactivo')
);

-- --------------------------------------------------------

--
-- Estructura para la vista `pacientes_estado`
--
DROP TABLE IF EXISTS `pacientes_estado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `pacientes_estado`  AS SELECT `usuarios`.`id` AS `id`, concat(`usuarios`.`primer_nombre`,' ',`usuarios`.`apellido_paterno`) AS `nombre_completo`, `pacientes`.`fecha_nacimiento` AS `fecha_nacimiento`, `pacientes`.`diagnostico_principal` AS `diagnostico_principal`, `pacientes`.`nivel_riesgo` AS `nivel_riesgo`, `pacientes`.`sexo` AS `sexo` FROM (`usuarios` join `pacientes` on(`usuarios`.`id` = `pacientes`.`usuario_id`)) WHERE `usuarios`.`estado` = 'Activo' ORDER BY `usuarios`.`created_at` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `total_pacientes`
--
DROP TABLE IF EXISTS `total_pacientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `total_pacientes`  AS SELECT count(`usuarios`.`id`) AS `total` FROM (`usuarios` join `roles` on(`usuarios`.`rol_id` = `roles`.`id`)) WHERE `roles`.`nombre` = 'Paciente' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `total_pacientes_estables`
--
DROP TABLE IF EXISTS `total_pacientes_estables`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `total_pacientes_estables`  AS SELECT count(0) AS `total` FROM `pacientes` WHERE `pacientes`.`nivel_riesgo` = 'Bajo' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `total_pacientes_riesgo_alto`
--
DROP TABLE IF EXISTS `total_pacientes_riesgo_alto`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `total_pacientes_riesgo_alto`  AS SELECT count(`pacientes`.`nivel_riesgo`) AS `total` FROM `pacientes` WHERE `pacientes`.`nivel_riesgo` = 'Alto' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_medicos`
--
DROP TABLE IF EXISTS `vista_medicos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_medicos`  AS SELECT `usuarios`.`id` AS `usuario_id`, `medicos`.`id` AS `medico_id`, concat(`usuarios`.`primer_nombre`,' ',`usuarios`.`apellido_paterno`) AS `nombre_completo`, `medicos`.`telefono` AS `telefono`, `usuarios`.`email` AS `email`, `medicos`.`cedula_profesional` AS `cedula_profesional`, `medicos`.`especialidad` AS `especialidad`, `usuarios`.`estado` AS `estado` FROM (`medicos` join `usuarios` on(`medicos`.`usuario_id` = `usuarios`.`id`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indices de la tabla `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indices de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indices de la tabla `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indices de la tabla `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `medicos`
--
ALTER TABLE `medicos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `medicos_usuario_id_unique` (`usuario_id`),
  ADD UNIQUE KEY `medicos_cedula_profesional_unique` (`cedula_profesional`);

--
-- Indices de la tabla `metricas`
--
ALTER TABLE `metricas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `metricas_nombre_unique` (`nombre`);

--
-- Indices de la tabla `metricas_pacientes`
--
ALTER TABLE `metricas_pacientes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `metricas_pacientes_tipo_metrica_id_foreign` (`tipo_metrica_id`),
  ADD KEY `metricas_pacientes_paciente_id_fecha_registro_index` (`paciente_id`,`fecha_registro`);

--
-- Indices de la tabla `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `pacientes`
--
ALTER TABLE `pacientes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pacientes_usuario_id_unique` (`usuario_id`),
  ADD KEY `pacientes_medico_id_foreign` (`medico_id`);

--
-- Indices de la tabla `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indices de la tabla `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `roles_nombre_unique` (`nombre`);

--
-- Indices de la tabla `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `usuarios_email_unique` (`email`),
  ADD KEY `usuarios_rol_id_foreign` (`rol_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `medicos`
--
ALTER TABLE `medicos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `metricas`
--
ALTER TABLE `metricas`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `metricas_pacientes`
--
ALTER TABLE `metricas_pacientes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `pacientes`
--
ALTER TABLE `pacientes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `medicos`
--
ALTER TABLE `medicos`
  ADD CONSTRAINT `medicos_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `metricas_pacientes`
--
ALTER TABLE `metricas_pacientes`
  ADD CONSTRAINT `metricas_pacientes_paciente_id_foreign` FOREIGN KEY (`paciente_id`) REFERENCES `pacientes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `metricas_pacientes_tipo_metrica_id_foreign` FOREIGN KEY (`tipo_metrica_id`) REFERENCES `metricas` (`id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `pacientes`
--
ALTER TABLE `pacientes`
  ADD CONSTRAINT `pacientes_medico_id_foreign` FOREIGN KEY (`medico_id`) REFERENCES `medicos` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `pacientes_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_rol_id_foreign` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
