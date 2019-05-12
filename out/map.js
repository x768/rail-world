'use strict';

(fn => {
    if (document.readyState !== 'loading'){
        fn();
    } else {
        document.addEventListener('DOMContentLoaded', fn);
    }
})(() => {
    const main = document.getElementById('main');
    const layer_station = document.getElementById('layer-station');
    let current_scroll = {x: -7130, y: -3320};
    let down_point = null;
    let scale = 1;

    function update_transform() {
        main.setAttribute('transform', 'translate(' + current_scroll.x + ',' + current_scroll.y + ') scale(' + scale + ')');
        if (scale < 0.5) {
            layer_station.style.display = 'none';
        } else {
            layer_station.style.display = '';
        }
    }

    document.addEventListener('mousedown', e => {
        if (e.button === 0) {
            down_point = {x: e.clientX, y: e.clientY};
        }
    });
    document.addEventListener('mouseup', e => {
        if (e.button === 0) {
            down_point = null;
        }
    });
    document.addEventListener('mousemove', e => {
        if (down_point !== null) {
            current_scroll.x += e.clientX - down_point.x;
            current_scroll.y += e.clientY - down_point.y;
            down_point.x = e.clientX;
            down_point.y = e.clientY;
            update_transform();
        }
    });
    document.addEventListener('wheel', e => {
        let prevX = (current_scroll.x - e.clientX) / scale;
        let prevY = (current_scroll.y - e.clientY) / scale;
        if (e.deltaY < 0) {
            if (scale < 1) {
                scale *= 2;
            }
        } else if (e.deltaY > 0) {
            if (scale > 0.25) {
                scale /= 2;
            }
        }
        current_scroll.x = (prevX * scale + e.clientX);
        current_scroll.y = (prevY * scale + e.clientY);
        update_transform();
    });

    update_transform();
});

