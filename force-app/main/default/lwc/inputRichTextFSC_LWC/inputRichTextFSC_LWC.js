import { LightningElement, api, track } from 'lwc';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';

export default class InputRichTextFSC_LWC extends LightningElement {
    @api value='';
    @track _field;
   

    handleValueChange(event) {
        console.log('entering handleValueChange');
        this._field = event.detail.value;
       // this.dispatchDataChangedEvent(this.fields.find(curField => curField.value === this._field));
        const valueChangeEvent = new FlowAttributeChangeEvent('value', event.detail.value);
        this.dispatchEvent(valueChangeEvent);
    
    }


        
    

}