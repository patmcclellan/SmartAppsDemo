import { LightningElement, api } from 'lwc';

export default class LevelThree extends LightningElement {
    @api recordId
    @api whatColor
    @api whichObject


    get colorspec(){
        return this.whatColor.toLowerCase();
    }

    get isRecordPage(){
        return this.recordId.length > 0;
    }
    

}