/*
    McWelling H Todman, mht47@drexel.edu
    CS530: DUI, Assignment [4]
*/

function searcher() {
    
    // proxy for easy reference inside of API response functions
    const that = this;

    this.popTable = function (data) {
        var searchForm = document.getElementById("search-form");
        var keyWords = searchForm.elements[0];

        for (var item = 0 ; item < data.length; item++){
            const currentItem = data[item];
            var divId = 'descriptionDiv' + item;
            var buttonId = 'expand-btn' + item;
            var linkId = 'http://localhost:8080/view?uid=' + currentItem.uid;

            const row = $(`
                <tr class="inventoryRow">
                    <td><img src=${currentItem.categoryImage}></img></td>
                    <td>
                        <a href=${linkId} style="font-weight:bold;color:blue">${currentItem.name}</a> <br>
                        ${currentItem.mailStreet} <br>
                        ${currentItem.mailCity}, ${currentItem.mailState}  ${currentItem.mailZIP}
                    </td>
                    <td width="50%">
                        <div class="descriptionBox" id="${divId}">
                        ${currentItem.mission}
                        </div>
                        <button type="button" id="${buttonId}">Read more</button>
                    </td>
                </tr>
            `);

            $(row).find("#"+buttonId).click(function () {
                $('#'+divId).css('height','auto');
            });

            $('#inventoryBody').append(row);
        }
    }

    // define search button functionality
    $('#search-btn').on("click", function (query) {
        var myForm = document.getElementById("search-form");
        
        var query = myForm.elements[0].value;
        
        $.get('/api/search', {
            query: query
        }, function (data) {
            that.popTable(data);
        });
    });

    // define return key functionality
    $("#search-bar").keypress(function(event) {
        if(event.keyCode==13) {
            var myForm = document.getElementById("search-form");
        
            var query = myForm.elements[0].value;

            $.get('/api/search', {
                query: query
            }, function (data) {
                that.popTable(data);
            });
        };
    });

    
}

