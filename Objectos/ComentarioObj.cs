using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.Objectos
{
    public class ComentarioObj
    {
        // --- Clave primaria ---
        public int ComentarioId { get; set; }

        // --- Relaciones ---
        public int TareaId { get; set; }
        public int UsuarioId { get; set; }

        // --- Datos del comentario ---
        public string Texto { get; set; }
        public DateTime FechaComentario { get; set; }

        // --- Campos calculados por sp_ObtenerComentariosPorTarea ---
        public string Autor { get; set; }  // Nombre + Apellido del usuario
        public string RolAutor { get; set; }  // Nombre del rol del usuario
    }
}