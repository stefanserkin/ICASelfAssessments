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
                console.log('::::: msp --> ', ans.questionType);
                ans.isTextArea = ans.questionType == 'Text Area';
                ans.isRatingScale = ans.questionType == 'Rating Scale';
                ans.isPicklist = ans.questionType == 'Picklist';
                ans.isMultiSelectPicklist = ans.questionType == 'Multi-Select Picklist';
                if (ans.isRatingScale) {
                    ans.options = this.getRatingScaleValues(ans);
                }
                if (ans.isPicklist || ans.isMultiSelectPicklist) {
                    ans.options = this.getPicklistValues(ans);
                    ans.numberOfValues = ans.options.length;
                    console.log('::: picklist values --> ', ans.options);
                    if (ans.isMultiSelectPicklist) {
                        ans.defaultValues = ans.answerText ? ans.answerText.split(';') : [];
                    }
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

    getPicklistValues(answer) {
        const values = [];
        if (answer.picklistValues) {
            answer.picklistValues.split(';').forEach(value => {
                values.push({label: value.toString(), value: value.toString()})
            });
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
            } else if (this.answers[answerIndex].questionType === 'Text Area' || this.answers[answerIndex].questionType === 'Picklist') {
                this.answers[answerIndex].answerText = selectedValue;
            } else if (this.answers[answerIndex].questionType === 'Multi-Select Picklist') {
                console.log(':::: is msp');
                console.log(':::: selectedValue --> ',selectedValue);
                this.answers[answerIndex].answerText = selectedValue ? selectedValue.join(';') : undefined;
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