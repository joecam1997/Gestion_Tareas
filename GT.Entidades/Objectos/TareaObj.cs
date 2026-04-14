using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.Objectos
{
    public class TareaObj
    {
        // --- Clave primaria ---
        public int TareaId { get; set; }

        // --- Relación con Proyecto ---
        public int ProyectoId { get; set; }
        public string ProyectoNombre { get; set; }   // viene del JOIN en sp_ConsultarTareas

        // --- Datos de la tarea ---
        public string Titulo { get; set; }
        public string Descripcion { get; set; }

        // --- Asignación (nullable: puede estar sin asignar) ---
        public int? AsignadoA { get; set; }
        public string AsignadoANombre { get; set; } // Nombre + Apellido del JOIN

        // --- Catálogo estado ---
        public int EstadoTareaId { get; set; }
        public string EstadoTareaNombre { get; set; } // viene del JOIN

        // --- Fechas ---
        public DateTime? FechaLimite { get; set; } // nullable
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }

        // --- Auditoría ---
        public int CreadoPor { get; set; }

        // --- Contador calculado por el SP ---
        public int TotalComentarios { get; set; }
    }
}