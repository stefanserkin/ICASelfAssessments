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
            console.log('assessment --> ',this.assessment);
            this.answers = this.assessment.answers;
            this.answers.forEach(ans => {
                ans.isTextArea = ans.questionType == 'Text Area';
                if (ans.questionType == 'Rating Scale') {
                    ans.options = this.getRatingScaleValues(ans);
                }
            });
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

    getRatingScaleValues(answer) {
        const values = [];
        for (let value = answer.minValue; value <= answer.maxValue; value += answer.step) {
            values.push(value);
        }
        return values;
    }

    handleRatingScaleChange(event) {
        const selectedRating = event.detail.value;
        console.log('Selected rating:', selectedRating);
    }

}