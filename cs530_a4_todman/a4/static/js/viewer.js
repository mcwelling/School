/*
    McWelling H Todman, mht47@drexel.edu
    CS530: DUI, Assignment [4]
*/

function viewer(charityData) {
    const that = this;

    // function to populate related organization links and data onto cards
    this.updateCards = function (data) {
        for (var item = 0 ; item < data.length; item++){
            const currentItem = data[item];
            var currentCard = item + 1;
            var linkId = 'http://localhost:8080/view?uid=' + currentItem.uid;

            const address1 = currentItem.mailStreet;
            
            const address2 =  currentItem.mailCity + ', ' + currentItem.mailState + ' ' + currentItem.mailZIP;

            $('#cardTitle'+currentCard).attr("href", linkId);
            $('#cardTitle'+currentCard).text(currentItem.name);
            $('#cardText'+currentCard).text(address1);
            $('#cardText'+currentCard).append(address2);
        }
    }

    $.get('/api/related', {
            query: charityData.mission
            ,uid: charityData.uid
        }, function (input) {
            that.updateCards(input);
        });
}