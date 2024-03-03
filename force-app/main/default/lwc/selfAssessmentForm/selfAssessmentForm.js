import { LightningElement, api, wire } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import getSelfAssessment from '@salesforce/apex/SelfAssessmentController.getSelfAssessment';
import submitSelfAssessment from '@salesforce/apex/SelfAssessmentController.submitSelfAssessment';

export default class SelfAssessmentForm extends LightningElement {
    @api recordId;
    @api cardTitle;
    @api cardIconName;

    isLoading = false;
    isSubmitted = false;
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
            this.isSubmitted = this.assessment.status == 'Completed';
            this.answers = this.assessment.answers;
            this.answers.forEach(ans => {
                ans.isTextArea = ans.questionType == 'Text Area';
                ans.isRatingScale = ans.questionType == 'Rating Scale';
                if (ans.isRatingScale) {
                    ans.options = this.getRatingScaleValues(ans);
                }
            });
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

    handleChange(event) {
        const selectedId = event.target.dataset.id;
        const selectedValue = event.detail.value;
        const answerIndex = this.answers.findIndex(answer => answer.id === selectedId);

        if (answerIndex !== -1) {
            if (this.answers[answerIndex].questionType === 'Rating Scale') {
                this.answers[answerIndex].answerNumber = Number(selectedValue);
            } else if (this.answers[answerIndex].questionType === 'Text Area') {
                this.answers[answerIndex].answerText = selectedValue;
            }
        }
    }

    handleSubmit() {
        console.log(':::: handle submit');
        console.log(':::: answers --> ' );
        console.table(this.answers);
        this.isLoading = true;

        // Is this helpful? Does it validate fields in child component?
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);
        
        if (allValid) {
            const request = JSON.stringify(this.answers);
            submitSelfAssessment({
                selfAssessmentId: this.recordId, 
                jsonAnswerString: request
            })
                .then((result) => {
                    console.log('::: result --> ', result);
                    this.isSubmitted = true;
                    this.isLoading = false;
                    this.dispatchEvent(new RefreshEvent());
                })
                .catch((error) => {
                    this.error = error;
                    console.error(this.error);
                    this.isLoading = false;
                });
        }
    }

}