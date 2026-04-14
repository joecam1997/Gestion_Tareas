using Gestion_Tareas.AccesoDatos;
using Gestion_Tareas.Logica;
using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static Gestion_Tareas.WebApp.Tareas.TareaDTO;

namespace Gestion_Tareas.WebApp.Tareas
{
    public partial class ListaTareas : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SesionBLL.HaySesion(Request))
                Response.Redirect("~/WebApp/Login.aspx");

        }

        [WebMethod]
        public static string ObtenerNombreSesion()
        {
            return SesionBLL.ObtenerNombreCompleto(HttpContext.Current.Request);
        }

        // Un solo viaje: proyectos, usuarios activos y estados de tarea
        [WebMethod]
        public static object ObtenerCatalogos()
        {
            var dal = new CatalogoDAL();

            // Proyectos como catálogo (Id, Descripcion)
            var proyectos = new List<CatalogoObj>();
            foreach (var p in new ProyectoBLL().Consultar())
                proyectos.Add(new CatalogoObj { Id = p.ProyectoId, Descripcion = p.Nombre });

            // Usuarios activos como catálogo
            var usuarios = new List<CatalogoObj>();
            foreach (var u in new UsuarioBLL().Consultar(activo: true))
                usuarios.Add(new CatalogoObj { Id = u.UsuarioId, Descripcion = u.Nombre + " " + u.Apellido });

            return new
            {
                Proyectos = proyectos,
                Usuarios = usuarios,
                EstadosTarea = dal.ObtenerEstadosTarea()
            };
        }

        [WebMethod]
        public static List<TareaDTO> Consultar(int? proyectoId, string titulo,
                                               int? asignadoA, int? estadoTareaId)
        {
            var lista = new TareaBLL().Consultar(
                proyectoId,
                string.IsNullOrEmpty(titulo) ? null : titulo,
                asignadoA,
                estadoTareaId
            );

            var resultado = new List<TareaDTO>();
            foreach (var t in lista)
            {
                resultado.Add(new TareaDTO
                {
                    TareaId = t.TareaId,
                    ProyectoNombre = t.ProyectoNombre,
                    Titulo = t.Titulo,
                    AsignadoANombre = t.AsignadoANombre,
                    EstadoTareaNombre = t.EstadoTareaNombre,
                    FechaLimiteStr = t.FechaLimite.HasValue
                                          ? t.FechaLimite.Value.ToString("dd/MM/yyyy") : null,
                    TotalComentarios = t.TotalComentarios
                });
            }
            return resultado;
        }

        [WebMethod]
        public static List<ComentarioDTO> ObtenerComentarios(int tareaId)
        {
            var lista = new TareaBLL().ObtenerComentarios(tareaId);
            var resultado = new List<ComentarioDTO>();
            foreach (var c in lista)
            {
                resultado.Add(new ComentarioDTO
                {
                    ComentarioId = c.ComentarioId,
                    Autor = c.Autor,
                    RolAutor = c.RolAutor,
                    Texto = c.Texto,
                    FechaStr = c.FechaComentario.ToString("dd/MM/yyyy HH:mm")
                });
            }
            return resultado;
        }

        [WebMethod]
        public static string InsertarComentario(int tareaId, string texto)
        {
            try
            {
                int usuarioId = SesionBLL.ObtenerUsuarioId(HttpContext.Current.Request);
                var c = new ComentarioObj
                {
                    TareaId = tareaId,
                    UsuarioId = usuarioId,
                    Texto = texto.Trim()
                };
                new TareaBLL().InsertarComentario(c);
                return "OK";
            }
            catch (Exception ex) { return "Error: " + ex.Message; }
        }

        [WebMethod]
        public static string Eliminar(int tareaId)
        {
            try
            {
                new TareaBLL().Eliminar(tareaId);
                return "OK";
            }
            catch (Exception ex) { return "Error: " + ex.Message; }
        }

        [WebMethod]
        public static void CerrarSesion()
        {
            SesionBLL.CerrarSesion(HttpContext.Current.Response);
        }
    }

    public class TareaDTO
    {
        public int TareaId { get; set; }
        public string ProyectoNombre { get; set; }
        public string Titulo { get; set; }
        public string AsignadoANombre { get; set; }
        public string EstadoTareaNombre { get; set; }
        public string FechaLimiteStr { get; set; }
        public int TotalComentarios { get; set; }


        public class ComentarioDTO
        {
            public int ComentarioId { get; set; }
            public string Autor { get; set; }
            public string RolAutor { get; set; }
            public string Texto { get; set; }
            public string FechaStr { get; set; }
        }
    }
}