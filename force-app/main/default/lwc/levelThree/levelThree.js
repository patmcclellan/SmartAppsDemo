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
                return "talk-bubble-in round left-top shadow tri-right-Blue protonLightBlue slds-p-top_large";
            case "Yellow":
                return "talk-bubble-in round left-top shadow tri-right-Yellow protonLightYellow slds-p-top_large";
            case "Green":
                return "talk-bubble-in round left-top shadow tri-right-Green protonLightGreen slds-p-top_large";
            case "Purple":
                return "talk-bubble-in round left-top shadow tri-right-Indigo protonLightIndigo slds-p-top_large";
            default:
                return "talk-bubble-in round left-top shadow tri-right-White protonWhite slds-p-top_large";
        }
    }
    
}