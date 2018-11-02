class PartnersController < ApplicationController
  include Importable

  def index
    @partners = current_organization.partners.order(:name)
  end

  def create
    @partner = current_organization.partners.new(partner_params)
    if @partner.save
      redirect_to partners_path, notice: "Partner added!"
    else
      flash[:error] = "Something didn't work quite right -- try again?"
      render action: :new
    end
  end

  def approve_application
    @partner = current_organization.partners.find(params[:id])
    @partner.update(status: "Approved")
    DiaperPartnerClient.put(@partner.attributes)
    redirect_to partners_path
  end

  def show
    @partner = current_organization.partners.find(params[:id])
  end

  def new
    @partner = current_organization.partners.new
  end

  def approve_partner
    @partner = current_organization.partners.find(params[:id])

    # TODO: create a service that abstracts all of this from PartnersController, like PartnerDetailRetriever.call(id: params[:id])

    # TODO: move this code to new service,
    @diaper_partner = DiaperPartnerClient.get(id: params[:id])
    @diaper_partner = JSON.parse(@diaper_partner, symbolize_names: true)
  end

  def edit
    @partner = current_organization.partners.find(params[:id])
  end

  def update
    @partner = current_organization.partners.find(params[:id])
    if @partner.update(partner_params)
      redirect_to partners_path, notice: "#{@partner.name} updated!"
    else
      flash[:error] = "Something didn't work quite right -- try again?"
      render action: :edit
    end
  end

  def destroy
    current_organization.partners.find(params[:id]).destroy
    redirect_to partners_path
  end

  private

  def partner_params
    params.require(:partner).permit(:name, :email)
  end
end
