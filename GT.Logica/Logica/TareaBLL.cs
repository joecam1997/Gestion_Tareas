
using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.Logica
{
    public class TareaBLL
    {
        private TareaDAL _dal = new TareaDAL();
        private UsuarioDAL _dalUsuario = new UsuarioDAL();

        // Estados de tarea según catálogo en la BD:
        // 1=Pendiente  2=En Progreso  3=En Revisión  4=Completada  5=Cancelada

        // -------------------------------------------------------
        //  Insertar tarea con validaciones
        //  Retorna: >0 = nuevo ID,
        //           -1 = usuario asignado no existe o está inactivo
        // -------------------------------------------------------
        public int Insertar(TareaObj t)
        {
            if (t.AsignadoA.HasValue && !UsuarioActivoValido(t.AsignadoA.Value))
                return -1;

            return _dal.Insertar(t);
        }

        // -------------------------------------------------------
        //  Actualizar tarea con validaciones
        //  Retorna: 0 = OK,
        //           -1 = usuario asignado no existe o está inactivo,
        //           -2 = transición de estado no permitida
        // -------------------------------------------------------
        public int Actualizar(TareaObj t)
        {
            // Validar usuario asignado
            if (t.AsignadoA.HasValue && !UsuarioActivoValido(t.AsignadoA.Value))
                return -1;

            // Validar transición de estado: no se puede reabrir una tarea Completada
            var tareaActual = _dal.ObtenerPorId(t.TareaId);
            if (tareaActual != null && tareaActual.EstadoTareaId == 4 && t.EstadoTareaId == 1)
                return -2;   // No se puede pasar de Completada a Pendiente

            _dal.Actualizar(t);
            return 0;
        }

        // -------------------------------------------------------
        //  Eliminar lógico (estado → Cancelada)
        // -------------------------------------------------------
        public void Eliminar(int tareaId)
        {
            _dal.Eliminar(tareaId);
        }

        // -------------------------------------------------------
        //  Consultar con filtros
        // -------------------------------------------------------
        public List<TareaObj> Consultar(int? proyectoId = null, string titulo = null,
                                        int? asignadoA = null, int? estadoTareaId = null)
        {
            return _dal.Consultar(proyectoId, titulo, asignadoA, estadoTareaId);
        }

        // -------------------------------------------------------
        //  Asignar tarea a un usuario
        //  Retorna: 0 = OK,  -1 = usuario no existe o está inactivo
        // -------------------------------------------------------
        public int Asignar(int tareaId, int usuarioId)
        {
            if (!UsuarioActivoValido(usuarioId))
                return -1;

            _dal.Asignar(tareaId, usuarioId);
            return 0;
        }

        // -------------------------------------------------------
        //  Insertar comentario
        // -------------------------------------------------------
        public int InsertarComentario(ComentarioObj c)
        {
            return _dal.InsertarComentario(c);
        }

        // -------------------------------------------------------
        //  Obtener comentarios de una tarea
        // -------------------------------------------------------
        public List<ComentarioObj> ObtenerComentarios(int tareaId)
        {
            return _dal.ObtenerComentarios(tareaId);
        }

        // -------------------------------------------------------
        //  Obtener tarea por ID
        // -------------------------------------------------------
        public TareaObj ObtenerPorId(int tareaId)
        {
            return _dal.ObtenerPorId(tareaId);
        }

        // -------------------------------------------------------
        //  Helper privado: verifica que el usuario exista y esté activo
        // -------------------------------------------------------
        private bool UsuarioActivoValido(int usuarioId)
        {
            var usuario = _dalUsuario.ObtenerPorId(usuarioId);
            return usuario != null && usuario.Activo;
        }
    }
}