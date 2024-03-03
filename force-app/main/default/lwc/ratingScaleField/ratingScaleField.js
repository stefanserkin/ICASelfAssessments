import { LightningElement, api, track } from 'lwc';

export default class RatingScaleField extends LightningElement {
    @api minValue = 1;
    @api maxValue = 5;
    @api step = 1;
    @api label;
    @api displayType;

    get values() {
        const step = this.step || 1;
        let values = [];
        for (let value = this.minValue; value <= this.maxValue; value += step) {
            values.push(value);
        }
        return values;
    }

    get picklistOptions() {
        return this.values.map(value => ({ label: value.toString(), value: value.toString() }));
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

    handleChange(event) {
        console.log('Selected rating:', event.target.value);
        const selectedValue = event.target.value;
        const valueChangeEvent = new CustomEvent('valuechange', {
            detail: { value: selectedValue }
        });
        this.dispatchEvent(valueChangeEvent);
    }
}