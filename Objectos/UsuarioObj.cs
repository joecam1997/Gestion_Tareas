using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.Objectos
{
    public class UsuarioObj
    {
        // --- Clave primaria ---
        public int UsuarioId { get; set; }

        // --- Datos personales ---
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Cedula { get; set; }
        public int GeneroId { get; set; }
        public string GeneroNombre { get; set; }   // viene del JOIN en sp_ConsultarUsuarios
        public DateTime FechaNacimiento { get; set; }
        public int EstadoCivilId { get; set; }
        public string EstadoCivilNombre { get; set; } // viene del JOIN
        public int RolId { get; set; }
        public string RolNombre { get; set; }   // viene del JOIN

        // --- Credenciales ---
        public string LoginUsuario { get; set; }
        public string Contrasena { get; set; }      // Hash SHA-256

        // --- Auditoría ---
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
    }
}