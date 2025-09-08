/// @desc Menu - Makes a menu, options provided in the form [["name", function, argument, selectable], [...]]
// TODO: this would have been easier using structs in an array such as [{ name: "Attack", func: funcAttack, args: -1, selectable: true}, ...]
function Menu(_x, _y, _options, _description = -1, _width = undefined, _height = undefined) {
    with (instance_create_depth(_x, _y, -99999, oMenu)) {
        options = _options;
        description = _description; // TODO: should remove this, this is leftover from a previous tutorial
        var _optionsCount = array_length(options);
        visibleOptionsMax = _optionsCount;
        
        // set up size
        xmargin = 10;
        ymargin = 8;
        draw_set_font(fnM5x7);
        heightLine = 12; // set this to avoid unpredictability
         
        // auto width
        if (_width == undefined) {
            width = 1;
            if (description != -1) {
                width = max(width, string_width(_description));
            }
            for (var i = 0; i < _optionsCount; i++) {
                width = max(width, string_width(_options[i][0]));
            }
            widthFull = width + xmargin * 2;
        } else {
            widthFull = _width;
        }
        
        // auto height
        if (_height == undefined) {
            height = heightLine * (_optionsCount + !(description == -1));
            heightFull = height + ymargin * 2;
        } else {
            heightFull = _height;
            
            // does it scroll?
            if (heightLine * (_optionsCount + !(description == -1)) > _height - (ymargin*2)) {
                scrolling = true;
                visibleOptionsMax = (_height - ymargin * 2) / heightLine;
            }
        }
    }
}

function SubMenu(_options) {
    // store old options in array and increase submenu level
    optionsAbove[subMenuLevel] = options;
    subMenuLevel++;
    options = _options;
    hover = 0; // reset hover
}

function MenuGoBack() {
    subMenuLevel--;
    options = optionsAbove[subMenuLevel];
    hover = 0; // reset hover
}

function MenuSelectAction(_user, _action) {
    with (oMenu) {
        active = false;
    }
    
    with (oBattle) {
        BeginAction(_user, _action, _user);
    }
    
    with (oMenu) {
        instance_destroy();
    }
}