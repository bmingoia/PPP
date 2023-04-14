import { LightningElement, wire, api } from 'lwc';
import { getCurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Trail__c from '@salesforce/schema/Trail__c';
import getTrailWrapper from '@salesforce/apex/LwcController.getTrailWrapper'

export default class MyComponent extends LightningElement {
    // Propiedades para almacenar los datos del trail
    trailName;
    trailDescription;
    trailEstimatedTime;
    trailTotalPoints;

    @api
    recordId;

    modules = []

    @wire(getTrailWrapper, { trailId: '$recordId' }) // Pasar el recordId como parámetro al método
    trailWrapper({ error, data }) {
        if (data) {
         //Extraer los valores del wrapper de Trail y asignarlos a las propiedades del componente
            this.trailName = data.trail.Name;
            this.trailDescription = data.trail.Description__c;
            this.trailEstimatedTime = data.trail.TotalTime__c;
            this.trailTotalPoints = data.trail.TotalPoints__c;
            this.modules = data.modules;
            console.log(data);
        } else if (error) {
            // Manejar errores si es necesario
            console.error('Error obteniendo el wrapper de Trail:', error);
        }
    }
}