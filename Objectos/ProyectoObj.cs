using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.Objectos
{
    public class ProyectoObj
    {
        // --- Clave primaria ---
        public int ProyectoId { get; set; }

        // --- Datos del proyecto ---
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }    // nullable: CHECK >= FechaInicio

        // --- Catálogo estado ---
        public int EstadoProyectoId { get; set; }
        public string EstadoProyectoNombre { get; set; } // viene del JOIN en sp_ConsultarProyectos

        // --- Auditoría ---
        public int CreadoPor { get; set; }
        public string CreadoPorNombre { get; set; } // Nombre + Apellido del JOIN
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }

        // --- Contadores calculados por el SP ---
        public int TotalTareas { get; set; }
        public int TareasCompletadas { get; set; }
    }
}