import { LightningElement, api } from 'lwc';

export default class RatingScaleField extends LightningElement {
    @api value;
    @api minValue = 1;
    @api maxValue = 5;
    @api step = 1;
    @api label;
    @api displayType;
    @api helpText;
    @api required = false;
    @api showValidity = false;

    @api validate() {
        // Assuming 'value' holds the current selection; add it if it's not already there
        const isValid = !this.required || this.value !== undefined;
        // Update the component to visually indicate validity
        const fieldContainer = this.template.querySelector('.field-container');
        if (fieldContainer) {
            fieldContainer.classList.toggle('required-invalid', !isValid);
        }
        return isValid;
    }

    get selectableOptions() {
        const step = this.step || 1;
        let values = [];
        for (let val = this.minValue; val <= this.maxValue; val += step) {
            values.push({
                label: val.toString(),
                value: val.toString(),
                checked: this.value === val
            });
        }
        return values;
    }

    get isRadio() {
        return this.displayType === 'Radio';
    }

    get isPicklist() {
        return this.displayType === 'Picklist';
    }

    get isSlider() {
        return this.displayType === 'Slider';
    }

    get radioGroupName() {
        return `rating-scale-${this.label}`;
    }

    handleChange(event) {
        this.value = event.target.value;
        const valueChangeEvent = new CustomEvent('valuechange', {
            detail: { value: this.value }
        });
        this.dispatchEvent(valueChangeEvent);
    }

    get fieldContainerClass() {
        return `field-container ${this.required && this.showValidity && !this.validate() ? 'required-invalid' : ''}`;
    }

    get showCustomAsterisk() {
        return this.required && this.displayType !== 'Picklist';
    }

}