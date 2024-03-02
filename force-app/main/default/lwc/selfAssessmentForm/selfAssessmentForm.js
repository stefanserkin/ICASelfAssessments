import { LightningElement, api, wire } from 'lwc';
import getSelfAssessment from '@salesforce/apex/SelfAssessmentController.getSelfAssessment';

export default class SelfAssessmentForm extends LightningElement {
    @api recordId;
    @api cardTitle = 'Self-Assessment Form';
    @api cardIconName = 'custom:custom18';

    isLoading = false;
    error;

    wiredAssessment = [];
    assessment;
    answers;

    @wire(getSelfAssessment, {recordId: '$recordId'})
    wiredResult(result) {
        this.isLoading = true;
        this.wiredAssessment = result;
        if (result.data) {
            this.assessment = JSON.parse(JSON.stringify(result.data));
            this.answers = this.assessment.answers;
            console.log(':::::::: answers --> ');
            console.table(this.answers);
            this.error = undefined;
            this.isLoading = false;
        } else if (result.error) {
            this.assessment = undefined;
            this.error = result.error;
            console.error(this.error);
            this.isLoading = false;
        }
    }

}