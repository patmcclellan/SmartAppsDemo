import { LightningElement, api } from 'lwc';

export default class LevelThree extends LightningElement {
    @api recordId
    @api whatColor
    @api whichObject


    get colorspec(){
        return this.whatColor.toLowerCase();
    }

    get isRecordPage(){
        return typeof this.recordId !== "undefined";
    }

    get talkbubble(){
        switch(this.whatColor){
            case "Blue":
                return "tri-right-Blue protonLightBlue";
            case "Yellow":
                return "tri-right-Yello protonLightYellow";
            case "Green":
                return "tri-right-Green protonLightGreen";
            case "Purple":
                return "tri-right-Indigo protonLightIndigo";
            default:
                return "tri-right-White protonWhite";
        }
    }
    
}