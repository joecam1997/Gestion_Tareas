using Gestion_Tareas.Objectos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Gestion_Tareas.Logica
{
    public class ProyectoBLL
    {
        private ProyectoDAL _dal = new ProyectoDAL();
        private TareaDAL _dalTarea = new TareaDAL();

        // -------------------------------------------------------
        //  Insertar proyecto con validaciones
        //  Retorna: >0 = nuevo ID,  -1 = fechas inválidas
        // -------------------------------------------------------
        public int Insertar(ProyectoObj p)
        {
            if (!FechasValidas(p.FechaInicio, p.FechaFin))
                return -1;

            return _dal.Insertar(p);
        }

        // -------------------------------------------------------
        //  Actualizar proyecto con validaciones
        //  Retorna: 0 = OK,  -1 = fechas inválidas
        // -------------------------------------------------------
        public int Actualizar(ProyectoObj p)
        {
            if (!FechasValidas(p.FechaInicio, p.FechaFin))
                return -1;

            _dal.Actualizar(p);
            return 0;
        }

        // -------------------------------------------------------
        //  Eliminar lógico con validación de tareas En Progreso
        //  Retorna: 0 = OK,  -2 = tiene tareas En Progreso
        // -------------------------------------------------------
        public int Eliminar(int proyectoId)
        {
            // EstadoTareaId = 2 → "En Progreso"
            var tareasEnProgreso = _dalTarea.Consultar(proyectoId: proyectoId, estadoTareaId: 2);

            if (tareasEnProgreso.Count > 0)
                return -2;

            _dal.Eliminar(proyectoId);
            return 0;
        }

        // -------------------------------------------------------
        //  Consultar con filtros
        // -------------------------------------------------------
        public List<ProyectoObj> Consultar(string nombre = null, int? estadoProyectoId = null)
        {
            return _dal.Consultar(nombre, estadoProyectoId);
        }

        // -------------------------------------------------------
        //  Obtener por ID
        // -------------------------------------------------------
        public ProyectoObj ObtenerPorId(int proyectoId)
        {
            return _dal.ObtenerPorId(proyectoId);
        }

        // -------------------------------------------------------
        //  Helpers privados
        // -------------------------------------------------------

        /// <summary>
        /// FechaFin debe ser mayor o igual a FechaInicio (o nula).
        /// </summary>
        private bool FechasValidas(DateTime inicio, DateTime? fin)
        {
            if (!fin.HasValue) return true;
            return fin.Value >= inicio;
        }
    }
}