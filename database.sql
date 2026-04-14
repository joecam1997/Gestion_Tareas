-- ============================================================
--  BASE DE DATOS: GestorTareas
--  Motor: SQL Server 2019
--  Descripción: Script completo de creación de tablas,
--               restricciones, datos de catálogo e índices
--  Proyecto: Prueba Práctica Programadores Web (Legacy)
-- ============================================================

USE master;
GO

-- Eliminar la base de datos si ya existe (entorno de desarrollo)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'GestorTareas')
BEGIN
    ALTER DATABASE GestorTareas SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GestorTareas;
END
GO

CREATE DATABASE GestorTareas
    COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE GestorTareas;
GO

-- ============================================================
--  SECCIÓN 1: TABLAS DE CATÁLOGO
-- ============================================================

-- ------------------------------------------------------------
--  Tabla: Genero
-- ------------------------------------------------------------
CREATE TABLE Genero (
    GeneroId    INT           NOT NULL IDENTITY(1,1),
    Descripcion NVARCHAR(50)  NOT NULL,
    Activo      BIT           NOT NULL DEFAULT 1,
    CONSTRAINT PK_Genero PRIMARY KEY (GeneroId),
    CONSTRAINT UQ_Genero_Descripcion UNIQUE (Descripcion)
);
GO

-- ------------------------------------------------------------
--  Tabla: EstadoCivil
-- ------------------------------------------------------------
CREATE TABLE EstadoCivil (
    EstadoCivilId INT           NOT NULL IDENTITY(1,1),
    Descripcion   NVARCHAR(50)  NOT NULL,
    Activo        BIT           NOT NULL DEFAULT 1,
    CONSTRAINT PK_EstadoCivil PRIMARY KEY (EstadoCivilId),
    CONSTRAINT UQ_EstadoCivil_Descripcion UNIQUE (Descripcion)
);
GO

-- ------------------------------------------------------------
--  Tabla: Rol
-- ------------------------------------------------------------
CREATE TABLE Rol (
    RolId       INT           NOT NULL IDENTITY(1,1),
    Nombre      NVARCHAR(50)  NOT NULL,
    Descripcion NVARCHAR(200) NULL,
    Activo      BIT           NOT NULL DEFAULT 1,
    CONSTRAINT PK_Rol PRIMARY KEY (RolId),
    CONSTRAINT UQ_Rol_Nombre UNIQUE (Nombre)
);
GO

-- ------------------------------------------------------------
--  Tabla: EstadoTarea (catálogo para el estado de una tarea)
-- ------------------------------------------------------------
CREATE TABLE EstadoTarea (
    EstadoTareaId INT           NOT NULL IDENTITY(1,1),
    Descripcion   NVARCHAR(50)  NOT NULL,
    Activo        BIT           NOT NULL DEFAULT 1,
    CONSTRAINT PK_EstadoTarea PRIMARY KEY (EstadoTareaId),
    CONSTRAINT UQ_EstadoTarea_Descripcion UNIQUE (Descripcion)
);
GO

-- ------------------------------------------------------------
--  Tabla: EstadoProyecto (catálogo para el estado de un proyecto)
-- ------------------------------------------------------------
CREATE TABLE EstadoProyecto (
    EstadoProyectoId INT           NOT NULL IDENTITY(1,1),
    Descripcion      NVARCHAR(50)  NOT NULL,
    Activo           BIT           NOT NULL DEFAULT 1,
    CONSTRAINT PK_EstadoProyecto PRIMARY KEY (EstadoProyectoId),
    CONSTRAINT UQ_EstadoProyecto_Descripcion UNIQUE (Descripcion)
);
GO

-- ============================================================
--  SECCIÓN 2: TABLAS PRINCIPALES
-- ============================================================

-- ------------------------------------------------------------
--  Tabla: Usuario
-- ------------------------------------------------------------
CREATE TABLE Usuario (
    UsuarioId       INT           NOT NULL IDENTITY(1,1),
    Nombre          NVARCHAR(100) NOT NULL,
    Apellido        NVARCHAR(100) NOT NULL,
    Cedula          NVARCHAR(20)  NOT NULL,
    GeneroId        INT           NOT NULL,
    FechaNacimiento DATE          NOT NULL,
    EstadoCivilId   INT           NOT NULL,
    RolId           INT           NOT NULL,
    LoginUsuario    NVARCHAR(50)  NOT NULL,
    Contrasena      NVARCHAR(256) NOT NULL,   -- Hash SHA-256
    Activo          BIT           NOT NULL DEFAULT 1,
    FechaCreacion   DATETIME      NOT NULL DEFAULT GETDATE(),
    FechaModificacion DATETIME    NULL,
    CONSTRAINT PK_Usuario        PRIMARY KEY (UsuarioId),
    CONSTRAINT UQ_Usuario_Cedula UNIQUE (Cedula),
    CONSTRAINT UQ_Usuario_Login  UNIQUE (LoginUsuario),
    CONSTRAINT FK_Usuario_Genero      FOREIGN KEY (GeneroId)      REFERENCES Genero(GeneroId),
    CONSTRAINT FK_Usuario_EstadoCivil FOREIGN KEY (EstadoCivilId) REFERENCES EstadoCivil(EstadoCivilId),
    CONSTRAINT FK_Usuario_Rol         FOREIGN KEY (RolId)         REFERENCES Rol(RolId)
);
GO

-- ------------------------------------------------------------
--  Tabla: Proyecto
-- ------------------------------------------------------------
CREATE TABLE Proyecto (
    ProyectoId        INT           NOT NULL IDENTITY(1,1),
    Nombre            NVARCHAR(150) NOT NULL,
    Descripcion       NVARCHAR(500) NULL,
    FechaInicio       DATE          NOT NULL,
    FechaFin          DATE          NULL,
    EstadoProyectoId  INT           NOT NULL,
    CreadoPor         INT           NOT NULL,   -- FK Usuario
    FechaCreacion     DATETIME      NOT NULL DEFAULT GETDATE(),
    FechaModificacion DATETIME      NULL,
    CONSTRAINT PK_Proyecto PRIMARY KEY (ProyectoId),
    CONSTRAINT FK_Proyecto_Estado   FOREIGN KEY (EstadoProyectoId) REFERENCES EstadoProyecto(EstadoProyectoId),
    CONSTRAINT FK_Proyecto_CreadoPor FOREIGN KEY (CreadoPor)       REFERENCES Usuario(UsuarioId),
    CONSTRAINT CK_Proyecto_Fechas   CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio)
);
GO

-- ------------------------------------------------------------
--  Tabla: Tarea
-- ------------------------------------------------------------
CREATE TABLE Tarea (
    TareaId           INT           NOT NULL IDENTITY(1,1),
    ProyectoId        INT           NOT NULL,
    Titulo            NVARCHAR(200) NOT NULL,
    Descripcion       NVARCHAR(1000) NULL,
    AsignadoA         INT           NULL,       -- FK Usuario (puede ser NULL hasta asignación)
    EstadoTareaId     INT           NOT NULL,
    FechaLimite       DATE          NULL,
    FechaCreacion     DATETIME      NOT NULL DEFAULT GETDATE(),
    FechaModificacion DATETIME      NULL,
    CreadoPor         INT           NOT NULL,
    CONSTRAINT PK_Tarea PRIMARY KEY (TareaId),
    CONSTRAINT FK_Tarea_Proyecto    FOREIGN KEY (ProyectoId)    REFERENCES Proyecto(ProyectoId),
    CONSTRAINT FK_Tarea_AsignadoA   FOREIGN KEY (AsignadoA)     REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_Tarea_Estado      FOREIGN KEY (EstadoTareaId) REFERENCES EstadoTarea(EstadoTareaId),
    CONSTRAINT FK_Tarea_CreadoPor   FOREIGN KEY (CreadoPor)     REFERENCES Usuario(UsuarioId)
);
GO

-- ------------------------------------------------------------
--  Tabla: Comentario
-- ------------------------------------------------------------
CREATE TABLE Comentario (
    ComentarioId    INT           NOT NULL IDENTITY(1,1),
    TareaId         INT           NOT NULL,
    UsuarioId       INT           NOT NULL,
    Texto           NVARCHAR(2000) NOT NULL,
    FechaComentario DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Comentario PRIMARY KEY (ComentarioId),
    CONSTRAINT FK_Comentario_Tarea   FOREIGN KEY (TareaId)   REFERENCES Tarea(TareaId),
    CONSTRAINT FK_Comentario_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);
GO

-- ============================================================
--  SECCIÓN 3: ÍNDICES (performance en búsquedas frecuentes)
-- ============================================================

CREATE INDEX IX_Usuario_Cedula        ON Usuario(Cedula);
CREATE INDEX IX_Usuario_Nombre        ON Usuario(Nombre, Apellido);
CREATE INDEX IX_Usuario_Login         ON Usuario(LoginUsuario);
CREATE INDEX IX_Tarea_ProyectoId      ON Tarea(ProyectoId);
CREATE INDEX IX_Tarea_AsignadoA       ON Tarea(AsignadoA);
CREATE INDEX IX_Comentario_TareaId    ON Comentario(TareaId);
CREATE INDEX IX_Proyecto_Estado       ON Proyecto(EstadoProyectoId);
GO

-- ============================================================
--  SECCIÓN 4: DATOS INICIALES DE CATÁLOGOS
-- ============================================================

-- Géneros
INSERT INTO Genero (Descripcion) VALUES
    ('Masculino'),
    ('Femenino'),
    ('Prefiero no indicar');
GO

-- Estados Civiles
INSERT INTO EstadoCivil (Descripcion) VALUES
    ('Soltero/a'),
    ('Casado/a'),
    ('Divorciado/a'),
    ('Viudo/a'),
    ('Unión de hecho');
GO

-- Roles del sistema
INSERT INTO Rol (Nombre, Descripcion) VALUES
    ('Administrador', 'Acceso total al sistema: usuarios, proyectos y tareas'),
    ('Líder de Proyecto', 'Puede crear y gestionar proyectos y asignar tareas'),
    ('Desarrollador', 'Puede ver y actualizar tareas asignadas'),
    ('Observador', 'Solo lectura sobre proyectos y tareas');
GO

-- Estados de Tarea
INSERT INTO EstadoTarea (Descripcion) VALUES
    ('Pendiente'),
    ('En Progreso'),
    ('En Revisión'),
    ('Completada'),
    ('Cancelada');
GO

-- Estados de Proyecto
INSERT INTO EstadoProyecto (Descripcion) VALUES
    ('Planificación'),
    ('En Desarrollo'),
    ('En Pruebas'),
    ('Completado'),
    ('Suspendido');
GO

-- ============================================================
--  SECCIÓN 5: USUARIO ADMINISTRADOR INICIAL
--  Contraseña: Admin123!  (hash SHA-256)
-- ============================================================
INSERT INTO Usuario (
    Nombre, Apellido, Cedula, GeneroId, FechaNacimiento,
    EstadoCivilId, RolId, LoginUsuario, Contrasena, Activo
) VALUES (
    'Administrador', 'Sistema', '0000000000',
    1, '1990-01-01',
    1, 1, 'admin',
    -- SHA-256 de "Admin123!" = a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3
    '3eb3fe66b31e3b4d10fa70b5cad49c7112294af6ae4e476a1c405155d45aa121',
    1
);
GO

-- ============================================================
--  SECCIÓN 6: STORED PROCEDURES
-- ============================================================

-- ----------------------------------------------------------
--  SP: Autenticación de usuario
-- ----------------------------------------------------------
CREATE PROCEDURE sp_AutenticarUsuario
    @LoginUsuario NVARCHAR(50),
    @Contrasena   NVARCHAR(256)   -- Hash SHA-256 enviado desde la app
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.UsuarioId,
        u.Nombre,
        u.Apellido,
        u.LoginUsuario,
        r.Nombre AS Rol
    FROM Usuario u
    INNER JOIN Rol r ON u.RolId = r.RolId
    WHERE u.LoginUsuario = @LoginUsuario
      AND u.Contrasena   = @Contrasena
      AND u.Activo       = 1;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Usuario - Insertar
-- ----------------------------------------------------------
CREATE PROCEDURE sp_InsertarUsuario
    @Nombre          NVARCHAR(100),
    @Apellido        NVARCHAR(100),
    @Cedula          NVARCHAR(20),
    @GeneroId        INT,
    @FechaNacimiento DATE,
    @EstadoCivilId   INT,
    @RolId           INT,
    @LoginUsuario    NVARCHAR(50),
    @Contrasena      NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Usuario WHERE Cedula = @Cedula)
    BEGIN
        SELECT -1 AS Resultado, 'Cédula ya registrada' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Usuario WHERE LoginUsuario = @LoginUsuario)
    BEGIN
        SELECT -2 AS Resultado, 'Usuario ya existe' AS Mensaje;
        RETURN;
    END

    INSERT INTO Usuario (Nombre, Apellido, Cedula, GeneroId, FechaNacimiento,
                         EstadoCivilId, RolId, LoginUsuario, Contrasena)
    VALUES (@Nombre, @Apellido, @Cedula, @GeneroId, @FechaNacimiento,
            @EstadoCivilId, @RolId, @LoginUsuario, @Contrasena);

    SELECT SCOPE_IDENTITY() AS Resultado, 'Usuario creado exitosamente' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Usuario - Actualizar
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ActualizarUsuario
    @UsuarioId       INT,
    @Nombre          NVARCHAR(100),
    @Apellido        NVARCHAR(100),
    @Cedula          NVARCHAR(20),
    @GeneroId        INT,
    @FechaNacimiento DATE,
    @EstadoCivilId   INT,
    @RolId           INT,
    @LoginUsuario    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Usuario WHERE Cedula = @Cedula AND UsuarioId <> @UsuarioId)
    BEGIN
        SELECT -1 AS Resultado, 'Cédula ya registrada en otro usuario' AS Mensaje;
        RETURN;
    END

    UPDATE Usuario SET
        Nombre            = @Nombre,
        Apellido          = @Apellido,
        Cedula            = @Cedula,
        GeneroId          = @GeneroId,
        FechaNacimiento   = @FechaNacimiento,
        EstadoCivilId     = @EstadoCivilId,
        RolId             = @RolId,
        LoginUsuario      = @LoginUsuario,
        FechaModificacion = GETDATE()
    WHERE UsuarioId = @UsuarioId;

    SELECT @UsuarioId AS Resultado, 'Usuario actualizado exitosamente' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Usuario - Eliminar (lógico)
-- ----------------------------------------------------------
CREATE PROCEDURE sp_EliminarUsuario
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Usuario SET Activo = 0, FechaModificacion = GETDATE()
    WHERE UsuarioId = @UsuarioId;
    SELECT @UsuarioId AS Resultado, 'Usuario desactivado' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: Consultar usuarios con filtros
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ConsultarUsuarios
    @Nombre   NVARCHAR(100) = NULL,
    @Apellido NVARCHAR(100) = NULL,
    @Cedula   NVARCHAR(20)  = NULL,
    @RolId    INT           = NULL,
    @Activo   BIT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.UsuarioId,
        u.Nombre,
        u.Apellido,
        u.Cedula,
        g.Descripcion  AS Genero,
        u.FechaNacimiento,
        ec.Descripcion AS EstadoCivil,
        r.Nombre       AS Rol,
        u.LoginUsuario,
        u.Activo,
        u.FechaCreacion
    FROM Usuario u
    INNER JOIN Genero      g  ON u.GeneroId      = g.GeneroId
    INNER JOIN EstadoCivil ec ON u.EstadoCivilId  = ec.EstadoCivilId
    INNER JOIN Rol         r  ON u.RolId          = r.RolId
    WHERE
        (@Nombre   IS NULL OR u.Nombre   LIKE '%' + @Nombre   + '%')
    AND (@Apellido IS NULL OR u.Apellido LIKE '%' + @Apellido + '%')
    AND (@Cedula   IS NULL OR u.Cedula   LIKE '%' + @Cedula   + '%')
    AND (@RolId    IS NULL OR u.RolId    = @RolId)
    AND (@Activo   IS NULL OR u.Activo   = @Activo)
    ORDER BY u.Apellido, u.Nombre;
END
GO

-- ----------------------------------------------------------
--  SP: Obtener usuario por ID
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ObtenerUsuarioPorId
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.UsuarioId, u.Nombre, u.Apellido, u.Cedula,
        u.GeneroId, g.Descripcion AS Genero,
        u.FechaNacimiento,
        u.EstadoCivilId, ec.Descripcion AS EstadoCivil,
        u.RolId, r.Nombre AS Rol,
        u.LoginUsuario, u.Activo
    FROM Usuario u
    INNER JOIN Genero      g  ON u.GeneroId      = g.GeneroId
    INNER JOIN EstadoCivil ec ON u.EstadoCivilId  = ec.EstadoCivilId
    INNER JOIN Rol         r  ON u.RolId          = r.RolId
    WHERE u.UsuarioId = @UsuarioId;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Proyecto - Insertar
-- ----------------------------------------------------------
CREATE PROCEDURE sp_InsertarProyecto
    @Nombre           NVARCHAR(150),
    @Descripcion      NVARCHAR(500),
    @FechaInicio      DATE,
    @FechaFin         DATE,
    @EstadoProyectoId INT,
    @CreadoPor        INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Proyecto (Nombre, Descripcion, FechaInicio, FechaFin, EstadoProyectoId, CreadoPor)
    VALUES (@Nombre, @Descripcion, @FechaInicio, @FechaFin, @EstadoProyectoId, @CreadoPor);
    SELECT SCOPE_IDENTITY() AS ProyectoId, 'Proyecto creado exitosamente' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Proyecto - Actualizar
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ActualizarProyecto
    @ProyectoId       INT,
    @Nombre           NVARCHAR(150),
    @Descripcion      NVARCHAR(500),
    @FechaInicio      DATE,
    @FechaFin         DATE,
    @EstadoProyectoId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Proyecto SET
        Nombre            = @Nombre,
        Descripcion       = @Descripcion,
        FechaInicio       = @FechaInicio,
        FechaFin          = @FechaFin,
        EstadoProyectoId  = @EstadoProyectoId,
        FechaModificacion = GETDATE()
    WHERE ProyectoId = @ProyectoId;
    SELECT @ProyectoId AS ProyectoId, 'Proyecto actualizado exitosamente' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Proyecto - Eliminar (lógico vía estado Suspendido)
-- ----------------------------------------------------------
CREATE PROCEDURE sp_EliminarProyecto
    @ProyectoId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Estado 5 = Suspendido (eliminación lógica)
    UPDATE Proyecto SET EstadoProyectoId = 5, FechaModificacion = GETDATE()
    WHERE ProyectoId = @ProyectoId;
    SELECT @ProyectoId AS ProyectoId, 'Proyecto suspendido' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: Consultar proyectos
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ConsultarProyectos
    @Nombre           NVARCHAR(150) = NULL,
    @EstadoProyectoId INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.ProyectoId, p.Nombre, p.Descripcion,
        p.FechaInicio, p.FechaFin,
        ep.Descripcion AS Estado,
        u.Nombre + ' ' + u.Apellido AS CreadoPor,
        p.FechaCreacion,
        (SELECT COUNT(*) FROM Tarea t WHERE t.ProyectoId = p.ProyectoId) AS TotalTareas,
        (SELECT COUNT(*) FROM Tarea t WHERE t.ProyectoId = p.ProyectoId
            AND t.EstadoTareaId = 4) AS TareasCompletadas
    FROM Proyecto p
    INNER JOIN EstadoProyecto ep ON p.EstadoProyectoId = ep.EstadoProyectoId
    INNER JOIN Usuario u         ON p.CreadoPor         = u.UsuarioId
    WHERE
        (@Nombre           IS NULL OR p.Nombre LIKE '%' + @Nombre + '%')
    AND (@EstadoProyectoId IS NULL OR p.EstadoProyectoId = @EstadoProyectoId)
    ORDER BY p.FechaCreacion DESC;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Tarea - Insertar
-- ----------------------------------------------------------
CREATE PROCEDURE sp_InsertarTarea
    @ProyectoId    INT,
    @Titulo        NVARCHAR(200),
    @Descripcion   NVARCHAR(1000),
    @AsignadoA     INT = NULL,
    @EstadoTareaId INT,
    @FechaLimite   DATE = NULL,
    @CreadoPor     INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Tarea (ProyectoId, Titulo, Descripcion, AsignadoA, EstadoTareaId, FechaLimite, CreadoPor)
    VALUES (@ProyectoId, @Titulo, @Descripcion, @AsignadoA, @EstadoTareaId, @FechaLimite, @CreadoPor);
    SELECT SCOPE_IDENTITY() AS TareaId, 'Tarea creada exitosamente' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Tarea - Actualizar
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ActualizarTarea
    @TareaId       INT,
    @Titulo        NVARCHAR(200),
    @Descripcion   NVARCHAR(1000),
    @AsignadoA     INT = NULL,
    @EstadoTareaId INT,
    @FechaLimite   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Tarea SET
        Titulo            = @Titulo,
        Descripcion       = @Descripcion,
        AsignadoA         = @AsignadoA,
        EstadoTareaId     = @EstadoTareaId,
        FechaLimite       = @FechaLimite,
        FechaModificacion = GETDATE()
    WHERE TareaId = @TareaId;
    SELECT @TareaId AS TareaId, 'Tarea actualizada exitosamente' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Tarea - Eliminar (lógico vía estado Cancelada)
-- ----------------------------------------------------------
CREATE PROCEDURE sp_EliminarTarea
    @TareaId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Estado 5 = Cancelada
    UPDATE Tarea SET EstadoTareaId = 5, FechaModificacion = GETDATE()
    WHERE TareaId = @TareaId;
    SELECT @TareaId AS TareaId, 'Tarea cancelada' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: Consultar tareas con filtros
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ConsultarTareas
    @ProyectoId    INT           = NULL,
    @Titulo        NVARCHAR(200) = NULL,
    @AsignadoA     INT           = NULL,
    @EstadoTareaId INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.TareaId,
        t.ProyectoId,
        p.Nombre  AS Proyecto,
        t.Titulo,
        t.Descripcion,
        t.AsignadoA,
        u.Nombre + ' ' + u.Apellido AS AsignadoANombre,
        t.EstadoTareaId,
        et.Descripcion AS EstadoTarea,
        t.FechaLimite,
        t.FechaCreacion,
        (SELECT COUNT(*) FROM Comentario c WHERE c.TareaId = t.TareaId) AS TotalComentarios
    FROM Tarea t
    INNER JOIN Proyecto  p  ON t.ProyectoId    = p.ProyectoId
    INNER JOIN EstadoTarea et ON t.EstadoTareaId = et.EstadoTareaId
    LEFT  JOIN Usuario   u  ON t.AsignadoA      = u.UsuarioId
    WHERE
        (@ProyectoId    IS NULL OR t.ProyectoId    = @ProyectoId)
    AND (@Titulo        IS NULL OR t.Titulo        LIKE '%' + @Titulo + '%')
    AND (@AsignadoA     IS NULL OR t.AsignadoA     = @AsignadoA)
    AND (@EstadoTareaId IS NULL OR t.EstadoTareaId = @EstadoTareaId)
    ORDER BY t.FechaCreacion DESC;
END
GO

-- ----------------------------------------------------------
--  SP: Asignar tarea a un usuario
-- ----------------------------------------------------------
CREATE PROCEDURE sp_AsignarTarea
    @TareaId   INT,
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Tarea SET
        AsignadoA         = @UsuarioId,
        FechaModificacion = GETDATE()
    WHERE TareaId = @TareaId;
    SELECT @TareaId AS TareaId, 'Tarea asignada exitosamente' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: CRUD Comentario - Insertar
-- ----------------------------------------------------------
CREATE PROCEDURE sp_InsertarComentario
    @TareaId   INT,
    @UsuarioId INT,
    @Texto     NVARCHAR(2000)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Comentario (TareaId, UsuarioId, Texto)
    VALUES (@TareaId, @UsuarioId, @Texto);
    SELECT SCOPE_IDENTITY() AS ComentarioId, 'Comentario agregado exitosamente' AS Mensaje;
END
GO

-- ----------------------------------------------------------
--  SP: Obtener comentarios de una tarea
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ObtenerComentariosPorTarea
    @TareaId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.ComentarioId,
        c.Texto,
        c.FechaComentario,
        u.Nombre + ' ' + u.Apellido AS Autor,
        r.Nombre AS RolAutor
    FROM Comentario c
    INNER JOIN Usuario u ON c.UsuarioId = u.UsuarioId
    INNER JOIN Rol     r ON u.RolId     = r.RolId
    WHERE c.TareaId = @TareaId
    ORDER BY c.FechaComentario DESC;
END
GO

-- ----------------------------------------------------------
--  SP: Obtener catálogos (para llenar combos)
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ObtenerGeneros
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GeneroId, Descripcion FROM Genero WHERE Activo = 1 ORDER BY Descripcion;
END
GO

CREATE PROCEDURE sp_ObtenerEstadosCiviles
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EstadoCivilId, Descripcion FROM EstadoCivil WHERE Activo = 1 ORDER BY Descripcion;
END
GO

CREATE PROCEDURE sp_ObtenerRoles
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RolId, Nombre, Descripcion FROM Rol WHERE Activo = 1 ORDER BY Nombre;
END
GO

CREATE PROCEDURE sp_ObtenerEstadosTarea
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EstadoTareaId, Descripcion FROM EstadoTarea WHERE Activo = 1 ORDER BY EstadoTareaId;
END
GO

CREATE PROCEDURE sp_ObtenerEstadosProyecto
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EstadoProyectoId, Descripcion FROM EstadoProyecto WHERE Activo = 1 ORDER BY EstadoProyectoId;
END
GO

-- ----------------------------------------------------------
--  SP: Reporte de usuarios (para ReportViewer)
-- ----------------------------------------------------------
CREATE PROCEDURE sp_ReporteUsuarios
    @Nombre   NVARCHAR(100) = NULL,
    @Apellido NVARCHAR(100) = NULL,
    @Cedula   NVARCHAR(20)  = NULL,
    @RolId    INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.UsuarioId,
        u.Nombre,
        u.Apellido,
        u.Cedula,
        g.Descripcion  AS Genero,
        CONVERT(VARCHAR(10), u.FechaNacimiento, 103) AS FechaNacimiento,
        ec.Descripcion AS EstadoCivil,
        r.Nombre       AS Rol,
        u.LoginUsuario,
        CASE u.Activo WHEN 1 THEN 'Activo' ELSE 'Inactivo' END AS Estado,
        CONVERT(VARCHAR(19), u.FechaCreacion, 120) AS FechaCreacion
    FROM Usuario u
    INNER JOIN Genero      g  ON u.GeneroId      = g.GeneroId
    INNER JOIN EstadoCivil ec ON u.EstadoCivilId  = ec.EstadoCivilId
    INNER JOIN Rol         r  ON u.RolId          = r.RolId
    WHERE
        (@Nombre   IS NULL OR u.Nombre   LIKE '%' + @Nombre   + '%')
    AND (@Apellido IS NULL OR u.Apellido LIKE '%' + @Apellido + '%')
    AND (@Cedula   IS NULL OR u.Cedula   LIKE '%' + @Cedula   + '%')
    AND (@RolId    IS NULL OR u.RolId    = @RolId)
    AND u.Activo = 1
    ORDER BY u.Apellido, u.Nombre;
END
GO

-- ============================================================
--  FIN DEL SCRIPT
-- ============================================================
PRINT 'Base de datos GestorTareas creada exitosamente.';
GO
