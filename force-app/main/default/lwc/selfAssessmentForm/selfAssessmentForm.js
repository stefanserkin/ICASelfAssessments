import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import getSelfAssessment from '@salesforce/apex/SelfAssessmentController.getSelfAssessment';
import submitSelfAssessment from '@salesforce/apex/SelfAssessmentController.submitSelfAssessment';

export default class SelfAssessmentForm extends NavigationMixin(LightningElement) {
    @api recordId;
    @api cardTitle;
    @api cardIconName;
    @api hideCardTitle = false;
    @api hideIntroMessage = false;

    isLoading = false;
    isSubmitted = false;
    error;

    wiredAssessment = [];
    assessment;
    answers = [];

    get showCardTitle() {
        return !this.hideCardTitle;
    }

    get showIntroMessage() {
        return !this.hideIntroMessage && this.assessment && this.assessment.introMessage;
    }

    @wire(getSelfAssessment, {recordId: '$recordId'})
    wiredResult(result) {
        this.isLoading = true;
        this.wiredAssessment = result;
        if (result.data) {
            this.assessment = JSON.parse(JSON.stringify(result.data));
            this.isSubmitted = this.assessment.status == 'Completed';
            this.answers = this.assessment.answers;
            this.answers.forEach(ans => {
                ans.isValid = true;
                ans.cssClass = 'slds-var-m-around_medium';
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
                this.answers[answerIndex].answerText = selectedValue ? selectedValue.join(';') : undefined;
            }
        }
    }

    handleSaveProgress() {
        this.isLoading = true;

        const request = JSON.stringify(this.answers);
        submitSelfAssessment({selfAssessmentId: this.recordId, jsonAnswerString: request, isFinalSubmit: false})
            .then((result) => {
                this.isLoading = false;
                this.dispatchEvent(new RefreshEvent());
                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Your progress has been saved.',
                    variant: 'success'
                });
                this.dispatchEvent(event);
            }).catch((error) => {
                this.error = error;
                console.error(this.error);
                this.isLoading = false;
            });
    }

    handleSubmit() {
        this.isLoading = true;
        let allValid = true;

        allValid = this.validateFormInput();

        if (!allValid) {
            this.error = 'Please correct errors before submitting.';
            this.isLoading = false;
            // Stop the form submission
            return;
        }
        
        // Submit form
        const request = JSON.stringify(this.answers);
        submitSelfAssessment({selfAssessmentId: this.recordId, jsonAnswerString: request, isFinalSubmit: true})
            .then((result) => {
                this.isSubmitted = true;
                this.isLoading = false;
                this.dispatchEvent(new RefreshEvent());
            }).catch((error) => {
                this.error = error;
                console.error(this.error);
                this.isLoading = false;
            });
    }

    validateFormInput() {
        console.table(this.answers);

        let isAllValid = true;

        // Loop through all answers to validate
        this.answers.forEach(answer => {
            let element;
            if (answer.isRatingScale) {
                element = this.template.querySelector(`c-rating-scale-field[data-id="${answer.id}"]`);
                if (!element.validate()) {
                    isAllValid = false;
                }
            } else if (answer.isTextArea) {
                let field = this.template.querySelector(`[data-id="${answer.id}"]`);
                if (!field.reportValidity()) {
                    isAllValid = false;
                }
            }
        });

        return isAllValid;
    }

}