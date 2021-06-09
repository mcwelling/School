/*
    McWelling H Todman, mht47@drexel.edu
    CS530: DUI, Assignment [2]
*/

function RentView(numRows, bikesPerRow) {
    
    // proxy for easy reference inside of API response functions
    const that = this;

    // header object containing reset button
    const header = $(`
        <tr>
            <th>Image</th>
            <th>Name</th>
            <th>Available</th>
            <th>
                <button id="reset-btn" class="reset-button btn btn-secondary">
                    Reset
                </button>
            </th>
        </tr>
    `);
    
    // append header row to table on rent.html
    $('#inventoryHeader').append(header);

    // define reset button functionality
    $('#reset-btn').on("click", function (available) {
        $.post('/api/reset_bikes', {
            available: 3
        }, function (data) {
            that.popTable(data);
        });
    });

    // fn to populate table body in rent.html
    this.popTable = function (bikes) {
        var root = "/static/img/bikes/";

        // clear rows from table body prior to repopulating
        $('#inventoryBody tr').remove();

        // loop to construct a table row for each bike
        for (var bike = 0; bike < bikes.length; bike++) {
            const currentBike = bikes[bike];
            
            const row = $(`
                <tr class="inventoryRow ${currentBike.available == 0 ? 'unavailable' : ''}">
                    <td><img src=${root.concat(currentBike.image)}></img></td>
                    <td>${currentBike.name}</td>
                    <td>${currentBike.available}</td>
                    <td style="white-space: nowrap">
                        <button 
                            id="decrement-btn" 
                            class="rent-button btn btn-tertiary"
                            style="white-space: nowrap">-</button>
                        <button 
                            id="increment-btn" 
                            class="rent-button btn btn-tertiary"
                            style="white-space: nowrap">+</button>
                    </td>
                </tr>
            `);

            // define decrement button functionality (available stock - 1)
            $(row).find("#decrement-btn").click(function () {
                that.update(currentBike, -1);
            });

            // disable decrement button when available stock == 0
            if (currentBike.available == 0) {
                $(row).find("#decrement-btn").attr("disabled", "disabled");
            }

            // define increment button functionality (available stock + 1)
            $(row).find('#increment-btn').click(function () {
                that.update(currentBike, 1);
            });

            $('#inventoryBody').append(row);
        }
    }
    
    // fn linking a get_bikes api call to the above populate table fn
    this.load = function () {
        $.get('/api/get_bikes', {
            n: numRows * bikesPerRow
        }, function (bikes) {
            that.popTable(bikes);
        });
    }

    // fn linking an update_bike api call to the above populate table fn
    this.update = function (bike, change) {
        $.post('/api/update_bike',{
            id: bike.id
            ,available: change
        }, function (data) {
            that.popTable(data);
        });
    }
}
