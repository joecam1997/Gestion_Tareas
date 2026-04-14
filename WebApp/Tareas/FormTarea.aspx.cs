using Gestion_Tareas.AccesoDatos;
using Gestion_Tareas.Logica;
using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Gestion_Tareas.WebApp.Tareas
{
    public partial class FormTarea : System.Web.UI.Page
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

        // Catálogos: proyectos, usuarios activos, estados de tarea
        [WebMethod]
        public static object ObtenerCatalogos()
        {
            var dal = new CatalogoDAL();

            var proyectos = new List<CatalogoObj>();
            foreach (var p in new ProyectoBLL().Consultar())
                proyectos.Add(new CatalogoObj { Id = p.ProyectoId, Descripcion = p.Nombre });

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

        // Obtener tarea por ID para modo edición (DTO con fechas como string)
        [WebMethod]
        public static object ObtenerPorId(int tareaId)
        {
            var t = new TareaBLL().ObtenerPorId(tareaId);
            if (t == null) return null;

            return new
            {
                t.TareaId,
                t.ProyectoId,
                t.Titulo,
                t.Descripcion,
                t.AsignadoA,
                t.EstadoTareaId,
                FechaLimiteStr = t.FechaLimite.HasValue
                                    ? t.FechaLimite.Value.ToString("dd/MM/yyyy") : null
            };
        }

        // Obtener comentarios con fechas como string
        [WebMethod]
        public static List<object> ObtenerComentarios(int tareaId)
        {
            var lista = new TareaBLL().ObtenerComentarios(tareaId);
            var resultado = new List<object>();
            foreach (var c in lista)
            {
                resultado.Add(new
                {
                    c.ComentarioId,
                    c.Autor,
                    c.RolAutor,
                    c.Texto,
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
                new TareaBLL().InsertarComentario(new ComentarioObj
                {
                    TareaId = tareaId,
                    UsuarioId = usuarioId,
                    Texto = texto.Trim()
                });
                return "OK";
            }
            catch (Exception ex) { return "Error: " + ex.Message; }
        }

        [WebMethod]
        public static string Guardar(int tareaId, int proyectoId, string titulo,
                                     string descripcion, int? asignadoA, int estadoTareaId,
                                     string fechaLimite)
        {
            try
            {
                DateTime? limite = null;
                if (!string.IsNullOrEmpty(fechaLimite))
                {
                    DateTime limVal;
                    if (!DateTime.TryParseExact(fechaLimite, "dd/MM/yyyy",
                            CultureInfo.InvariantCulture, DateTimeStyles.None, out limVal))
                        return "Formato de fecha límite inválido. Use dd/mm/aaaa.";
                    limite = limVal;
                }

                var t = new TareaObj
                {
                    TareaId = tareaId,
                    ProyectoId = proyectoId,
                    Titulo = titulo.Trim(),
                    Descripcion = string.IsNullOrEmpty(descripcion) ? null : descripcion.Trim(),
                    AsignadoA = asignadoA,
                    EstadoTareaId = estadoTareaId,
                    FechaLimite = limite,
                    CreadoPor = SesionBLL.ObtenerUsuarioId(HttpContext.Current.Request)
                };

                var bll = new TareaBLL();
                int resultado;

                if (tareaId == 0)
                    resultado = bll.Insertar(t);
                else
                {
                    resultado = bll.Actualizar(t);
                    if (resultado == 0) return "OK";
                }

                switch (resultado)
                {
                    case -1: return "El usuario asignado no existe o está inactivo.";
                    case -2: return "No se puede regresar una tarea Completada a estado Pendiente.";
                    default:
                        return resultado > 0 ? "OK" : "No se pudo guardar la tarea.";
                }
            }
            catch (Exception ex)
            {
                return "Error inesperado: " + ex.Message;
            }
        }

        [WebMethod]
        public static void CerrarSesion()
        {
            SesionBLL.CerrarSesion(HttpContext.Current.Response);
        }
    }
}
