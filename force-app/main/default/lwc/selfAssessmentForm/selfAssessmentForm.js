import { LightningElement, api, wire } from 'lwc';
import getAnswers from '@salesforce/apex/SelfAssessmentController.getAnswers';

export default class SelfAssessmentForm extends LightningElement {
    @api recordId;
    @api cardTitle = 'Self-Assessment Form';
    @api cardIconName = 'custom:custom18';

    isLoading = false;
    error;

    wiredAnswers = [];
    answers;

    @wire(getAnswers, {selfAssessmentId: '$recordId'})
    wiredResult(result) {
        this.isLoading = true;
        this.wiredAnswers = result;
        if (result.data) {
            let rows = JSON.parse(JSON.stringify(result.data));
            this.answers = rows;
            console.log(':::::::: answers --> ');
            console.table(this.answers);
            this.error = undefined;
            this.isLoading = false;
        } else if (result.error) {
            this.answers = undefined;
            this.error = result.error;
            console.error(this.error);
            this.isLoading = false;
        }
    }

}