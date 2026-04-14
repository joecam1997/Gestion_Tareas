/* ============================================================
   GestorTareas — app.js
   Requiere: jQuery 1.x + jQuery UI (datepicker + tooltip + dialog)
   ============================================================ */

$(function () {

    /* ── Tooltips globales ───────────────────────────────────── */
    $(document).tooltip({
        position: { my: "left+10 center", at: "right center" },
        show: { delay: 300 }
    });

    /* ── Datepicker global (se activa en campos con clase .gt-date) */
    $(".gt-date").datepicker({
        dateFormat: "dd/mm/yy",
        maxDate: "0",           // no fechas futuras (para FechaNacimiento)
        changeYear: true,
        changeMonth: true,
        yearRange: "-100:+0"
    });

    /* ── Datepicker para fechas sin restricción (proyectos/tareas) */
    $(".gt-date-free").datepicker({
        dateFormat: "dd/mm/yy",
        changeYear: true,
        changeMonth: true,
        yearRange: "2000:+10"
    });

    /* ── Mensaje flash: ocultar automáticamente tras 4 segundos ─ */
    setTimeout(function () {
        $(".gt-alert").fadeOut(400);
    }, 4000);

});

/* ── Helper: mostrar alerta dinámica ────────────────────────── */
function gtMostrarAlerta(tipo, mensaje, contenedor) {
    var css = "gt-alert gt-alert-" + tipo;
    var html = '<div class="' + css + '">' + mensaje + '</div>';
    var $c = contenedor ? $(contenedor) : $("#gt-alertas");
    $c.html(html);
    setTimeout(function () { $c.find(".gt-alert").fadeOut(400); }, 4000);
}

/* ── Helper: diálogo de confirmación reutilizable ───────────── */
function gtConfirmar(mensaje, callback) {
    $('<div title="Confirmar acción"><p>' + mensaje + '</p></div>').dialog({
        modal: true,
        width: 380,
        resizable: false,
        buttons: {
            "Sí, continuar": function () {
                $(this).dialog("close");
                callback();
            },
            "Cancelar": function () {
                $(this).dialog("close");
            }
        }
    });
}

/* ── Helper: deshabilitar botón durante llamada al servidor ──── */
function gtBloquearBtn(btn) {
    $(btn).prop("disabled", true).css("opacity", "0.6");
}

function gtDesbloquearBtn(btn) {
    $(btn).prop("disabled", false).css("opacity", "1");
}

/* ── Helper: limpiar tabla HTML ─────────────────────────────── */
function gtLimpiarTabla(tbodyId) {
    $("#" + tbodyId).empty();
}

/* ── Helper: construir fila de tabla ────────────────────────── */
function gtFila(celdas) {
    var tr = "<tr>";
    $.each(celdas, function (i, v) { tr += "<td>" + v + "</td>"; });
    tr += "</tr>";
    return tr;
}

/* ── Helper: badge de estado según texto ────────────────────── */
function gtBadge(texto) {
    var mapa = {
        "Pendiente": "gray",
        "En Progreso": "blue",
        "En Revisión": "yellow",
        "Completada": "green",
        "Cancelada": "red",
        "Planificación": "gray",
        "En Desarrollo": "blue",
        "En Pruebas": "yellow",
        "Completado": "green",
        "Suspendido": "red",
        "Activo": "green",
        "Inactivo": "red"
    };
    var color = mapa[texto] || "gray";
    return '<span class="gt-badge gt-badge-' + color + '">' + texto + '</span>';
}