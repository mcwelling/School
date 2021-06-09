/*
    McWelling H Todman, mht47@drexel.edu
    CS530: DUI, Assignment [3]
*/

// global array is recycled -- holds datapoints to be plotted
var dataset = [];

function Grapher() {

    // implement your Grapher here
    const that = this;

    // initial build function. recalled each time graph refereshes after keyup
    this.build = function (location) {
        var newCanvas = $('<canvas/>',{id: 'canvas', class: 'canvas'}).prop({width: 700, height: 420});
        $(location).append(newCanvas);

        ctx = document.getElementById('canvas').getContext("2d");
        ctx.beginPath();
        ctx.strokeStyle = "#C0C0C0";
        ctx.lineWidth = 1;

        // draw background lines
        for (var i = 0; i < 20; i++) {
            ctx.moveTo(i*35,0);
            ctx.lineTo(i*35, 420);
            ctx.stroke();
        }

        for (var j = 0; j < 12; j++) {
            ctx.moveTo(0,j*35);
            ctx.lineTo(700,j*35);
            ctx.stroke();
        }

        // draw horizontal and vertical axes
        ctx.beginPath();
        ctx.strokeStyle = "#000000";
        ctx.lineWidth = 2;
        
        ctx.moveTo(350,0);
        ctx.lineTo(350, 420);
        ctx.stroke();

        ctx.moveTo(0,210);
        ctx.lineTo(700,210);
        ctx.stroke();

        // insert labels
        ctx.beginPath();
        ctx.font = "12px Helvetica";
        ctx.strokeStyle = "#C0C0C0";

        for (var i = 0; i < 21; i++) {
            ctx.fillText((-10 + i).toString(), i*35, 225);
        }

        for (var j = 0; j < 13; j++) {
            ctx.fillText((6 - j).toString(), 335, j*35);
        }
    }
    
    // function to generate the cartesian dataset from user input
    this.generateData = function (third=0, second=0, first=0, constant=0) {
        
        if(dataset.length > 0) {
            dataset.splice(0, dataset.length);
        }
        
        for (var range = -10; range <= 10; range+=0.01) {
            var observation = evaluate(third, second, first, constant, range);
            
            if (observation <= 6 && observation >= -6) {
                var dataPoint = [range, observation];
                dataset.push(dataPoint);
            }
        }
    }

    // function to plot the translated cartesian datapoints to canvas coordinates
    this.plot = function (dataset) {
        plot_ctx = document.getElementById('canvas').getContext("2d");
        plot_ctx.beginPath();
        plot_ctx.strokeStyle = "#0000FF";
        plot_ctx.lineWidth = 2;

        var current_record = [];
        var previous_record = [];
        
        // loop draws lines between successive coordinates from dataset
        for(var record = 0; record < dataset.length; record++) {
            
            if (previous_record.length > 0) {
                current_record = translate(dataset[record][0], dataset[record][1]);
                plot_ctx.moveTo(previous_record[0], previous_record[1]);
                plot_ctx.lineTo(current_record[0], current_record[1]);
                plot_ctx.stroke();
                previous_record = current_record;
                current_record.splice(0,current_record.length);
            } else {
                previous_record = translate(dataset[record][0], dataset[record][1]);
            }
        }
    }
}

// helper function to translate cartesian dataset into canvas coordinates
function translate (x, y) {
    var horizontal = (x+10) * 35;
    var vertical = (6-y) * 35;
    var record = [horizontal, vertical];

    return record;
}
// helper function to translate canvas coordinates into cartesian coordinates
function detranslate (x,y) {
    var horizontal = x/35 - 10;
    var vertical = 6 - y/35;
    var record = [horizontal, vertical];

    return record;
}

// helper function to evalutate the user input polynomial (returns y value)
function evaluate (three=0, two=0, one=0, zero=0, x) {
    var y = (
        (three * Math.pow(x, 3))
        + (two * Math.pow(x, 2))
        + (one * x)
        + zero);

    return y;
}
